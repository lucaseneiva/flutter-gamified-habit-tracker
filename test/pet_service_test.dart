// test/pet_service_test.dart
import 'package:fake_async/fake_async.dart';
import 'package:firy_streak/features/pet_management/data/pet_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clock/clock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:firy_streak/features/pet_management/domain/pet_state.dart';

void main() {
  group('PetService Time-Dependent Tests', () {
    // Dados de setup
    const String userId = 'test_user_id';
    final mockUser = MockUser(uid: userId, email: 'test@test.com');
    final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    final initialUserData = {
      'email': 'test@test.com',
      'streakCount': 0,
      'lastFedTimestamp': null,
    };

    // Este teste está correto, pois não usa async
    test('should return EGG state for a new user', () {
      final firestore = FakeFirebaseFirestore();
      final service = PetService(firestore: firestore, auth: auth, clock: const Clock());
      final stage = service.determineCurrentFiryState(initialUserData).stage;
      expect(stage, GrowthStage.egg);
    });

    test('feeding the pet updates timestamp', () {
      // 1. A função externa NÃO é async
      fakeAsync((async) {
        // 2. Setup
        final firestore = FakeFirebaseFirestore();
        final fixedClock = Clock.fixed(DateTime(2024, 1, 1, 10, 0));
        final service = PetService(firestore: firestore, auth: auth, clock: fixedClock);

        // 3. Act
        // Adiciona dados iniciais. É uma operação async, então chamamos e damos flush.
        firestore.collection('users').doc(userId).set(initialUserData);
        async.flushMicrotasks(); // Executa o 'set'

        // Chama a função principal do teste. Também é async.
        service.feedPet();
        async.flushMicrotasks(); // Executa o 'update' dentro de feedPet()

        // 4. Assert
        // Agora, para verificar o resultado, precisamos buscar os dados, que também é async.
        firestore.collection('users').doc(userId).get().then((snapshot) {
          final data = snapshot.data();
          expect(data?['streakCount'], 1);
          expect(data?['lastFedTimestamp'].toDate(), DateTime(2024, 1, 1, 10, 0));
        });
        
        async.flushMicrotasks(); // Executa o 'get' e o código dentro do '.then()'
      });
    });
    // =================================================================

    // Os outros testes já estavam corretos, pois não chamavam funções async
    test('after 25 hours, status should be NOT_FED', () {
      fakeAsync((async) {
        final firestore = FakeFirebaseFirestore();
        final lastFed = DateTime(2024, 1, 1, 10, 0);
        final clock = async.getClock(lastFed);
        final service = PetService(firestore: firestore, auth: auth, clock: clock);

        final fedUserData = {
          'FiryState': 'FED',
          'streakCount': 1,
          'lastFedTimestamp': Timestamp.fromDate(lastFed),
        };


        async.elapse(const Duration(hours: 25));
        
        final currentStatus = service.determineCurrentFiryState(fedUserData).status;
        expect(currentStatus, FeedingStatus.notFed);
      });
    });

    test('after 49 hours, state should be DEAD', () {
      fakeAsync((async) {
        final firestore = FakeFirebaseFirestore();
        final lastFed = DateTime(2024, 1, 1, 10, 0);
        var clock = async.getClock(lastFed);
        final service = PetService(firestore: firestore, auth: auth, clock: clock);

        final fedUserData = {
          'streakCount': 5,
          'lastFedTimestamp': Timestamp.fromDate(lastFed),
        };
        
        // print('Current time: ${clock.now()}');
        async.elapse(const Duration(hours: 49));
        // print('Current time: ${clock.now()}');
        
        final currentState = service.determineCurrentFiryState(fedUserData);
        expect(currentState.isDead, true);
      });
    });
  });
}

