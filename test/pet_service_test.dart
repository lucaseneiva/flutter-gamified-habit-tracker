// test/pet_service_test.dart
import 'package:fake_async/fake_async.dart';
import 'package:firy_streak/features/pet_management/data/pet_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clock/clock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:firy_streak/features/pet_management/domain/pet_state.dart';
import 'package:firy_streak/features/pet_management/domain/pet_model.dart';

void main() {
  group('PetService Time-Dependent Tests', () {
    // Dados de setup
    const String userId = 'test_user_id';
    final mockUser = MockUser(uid: userId, email: 'test@test.com');
    final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    final initialPetModel = PetModel(lastFedTimestamp: null, streakCount: 0);

    test('should return BABY state with NOT_FED status for a new user', () {
      final firestore = FakeFirebaseFirestore();
      final service = PetService(
        firestore: firestore,
        auth: auth,
        clock: const Clock(),
      );
      final state = service.determineCurrentFiryState(initialPetModel);
      expect(state.stage, GrowthStage.baby);
      expect(state.status, FeedingStatus.notFed);
    });

    test('feeding the pet updates timestamp', () {
      fakeAsync((async) {
        final firestore = FakeFirebaseFirestore();
        final fixedClock = Clock.fixed(DateTime(2024, 1, 1, 10, 0));
        final service = PetService(
          firestore: firestore,
          auth: auth,
          clock: fixedClock,
        );

        // Adiciona dados iniciais
        firestore.collection('users').doc(userId).set(initialPetModel);
        async.flushMicrotasks();

        // Alimenta o pet
        service.feedPet();
        async.flushMicrotasks();

        // Verifica se foi atualizado
        firestore.collection('users').doc(userId).get().then((snapshot) {
          final data = snapshot.data();
          expect(data?['streakCount'], 1);
          expect(
            data?['lastFedTimestamp'].toDate(),
            DateTime(2024, 1, 1, 10, 0),
          );
        });

        async.flushMicrotasks();
      });
    });

    test('same day feeding - status should remain FED', () {
      fakeAsync((async) {
        final firestore = FakeFirebaseFirestore();
        final lastFed = DateTime(2024, 1, 1, 10, 0); // 10:00 AM
        final clock = async.getClock(lastFed);
        final service = PetService(
          firestore: firestore,
          auth: auth,
          clock: clock,
        );

        final fedUserData = {
          'streakCount': 1,
          'lastFedTimestamp': Timestamp.fromDate(lastFed),
        };

        // Avança para 23:59 do mesmo dia
        async.elapse(const Duration(hours: 13, minutes: 59));

        final currentStatus = service
            .determineCurrentFiryState(fedUserData)
            .status;
        expect(currentStatus, FeedingStatus.fed);
      });
    });

    test('next day at midnight - status should be NOT_FED', () {
      fakeAsync((async) {
        final firestore = FakeFirebaseFirestore();
        final lastFed = DateTime(2024, 1, 1, 18, 45); // 18:45 (6:45 PM)
        final clock = async.getClock(lastFed);
        final service = PetService(
          firestore: firestore,
          auth: auth,
          clock: clock,
        );

        final fedUserData = {
          'streakCount': 1,
          'lastFedTimestamp': Timestamp.fromDate(lastFed),
        };

        // Avança para o próximo dia (passa da meia-noite)
        async.elapse(const Duration(hours: 5, minutes: 16)); // Vai para 00:01 do dia 2

        final currentStatus = service
            .determineCurrentFiryState(fedUserData)
            .status;
        expect(currentStatus, FeedingStatus.notFed);
      });
    });

    test('after 2 full days without feeding - state should be DEAD', () {
      fakeAsync((async) {
        final firestore = FakeFirebaseFirestore();
        final lastFed = DateTime(2024, 1, 1, 10, 0); // Dia 1, 10:00 AM
        var clock = async.getClock(lastFed);
        final service = PetService(
          firestore: firestore,
          auth: auth,
          clock: clock,
        );

        final fedUserData = {
          'streakCount': 5,
          'lastFedTimestamp': Timestamp.fromDate(lastFed),
        };

        // Avança para o dia 3 (2 dias completos depois)
        async.elapse(const Duration(days: 2, hours: 1)); // Vai para dia 3, 11:00 AM

        final currentState = service.determineCurrentFiryState(fedUserData);
        expect(currentState.stage, GrowthStage.dead);
      });
    });

    test('feeding on day 1 at 23:59, checking at day 2 at 00:01', () {
      fakeAsync((async) {
        final firestore = FakeFirebaseFirestore();
        final lastFed = DateTime(2024, 1, 1, 23, 59); // Quase meia-noite do dia 1
        final clock = async.getClock(lastFed);
        final service = PetService(
          firestore: firestore,
          auth: auth,
          clock: clock,
        );

        final fedUserData = {
          'streakCount': 1,
          'lastFedTimestamp': Timestamp.fromDate(lastFed),
        };

        // Avança apenas 2 minutos (cruza a meia-noite)
        async.elapse(const Duration(minutes: 2)); // Vai para 00:01 do dia 2

        final currentStatus = service
            .determineCurrentFiryState(fedUserData)
            .status;
        expect(currentStatus, FeedingStatus.notFed);
      });
    });

    test('growth stages based on streak count', () {
      final firestore = FakeFirebaseFirestore();
      final service = PetService(
        firestore: firestore,
        auth: auth,
        clock: Clock.fixed(DateTime(2024, 1, 1)),
      );

      final currentTime = DateTime(2024, 1, 1);

      // Baby (1-9 streak)
      final babyData = {
        'streakCount': 5,
        'lastFedTimestamp': Timestamp.fromDate(currentTime),
      };
      expect(service.determineCurrentFiryState(babyData).stage, GrowthStage.baby);

      // Child (10-29 streak)
      final childData = {
        'streakCount': 15,
        'lastFedTimestamp': Timestamp.fromDate(currentTime),
      };
      expect(service.determineCurrentFiryState(childData).stage, GrowthStage.child);

      // Teen (30-59 streak)
      final teenData = {
        'streakCount': 45,
        'lastFedTimestamp': Timestamp.fromDate(currentTime),
      };
      expect(service.determineCurrentFiryState(teenData).stage, GrowthStage.teen);

      // Adult (60+ streak)
      final adultData = {
        'streakCount': 100,
        'lastFedTimestamp': Timestamp.fromDate(currentTime),
      };
      expect(service.determineCurrentFiryState(adultData).stage, GrowthStage.adult);
    });
  });
}