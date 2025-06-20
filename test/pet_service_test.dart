// test/pet_service_test.dart
import 'package:fake_async/fake_async.dart';
import 'package:firy_streak/pet_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clock/clock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

void main() {
  group('PetService Time-Dependent Tests', () {
    // Dados de setup
    const String userId = 'test_user_id';
    final mockUser = MockUser(uid: userId, email: 'test@test.com');
    final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    final initialUserData = {
      'email': 'test@test.com',
      'fieryState': 'EGG',
      'streakCount': 0,
      'lastFedTimestamp': null,
    };

    // Este teste está correto, pois não usa async
    test('should return EGG state for a new user', () {
      final firestore = FakeFirebaseFirestore();
      final service = PetService(firestore: firestore, auth: auth, clock: const Clock());
      final state = service.determineCurrentFieryState(initialUserData);
      expect(state, 'EGG');
    });

    // =================================================================
    // CORREÇÃO APLICADA AQUI
    // =================================================================
    test('feeding the pet changes state to FED and updates timestamp', () {
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
          expect(data?['fieryState'], 'FED');
          expect(data?['streakCount'], 1);
          expect(data?['lastFedTimestamp'].toDate(), DateTime(2024, 1, 1, 10, 0));
        });
        
        async.flushMicrotasks(); // Executa o 'get' e o código dentro do '.then()'
      });
    });
    // =================================================================

    // Os outros testes já estavam corretos, pois não chamavam funções async
    test('after 25 hours, state should be NOT_FED', () {
      fakeAsync((async) {
        final firestore = FakeFirebaseFirestore();
        final fedTime = DateTime(2024, 1, 1, 10, 0);
        final clock = Clock.fixed(fedTime);
        final service = PetService(firestore: firestore, auth: auth, clock: clock);

        final fedUserData = {
          'fieryState': 'FED',
          'streakCount': 1,
          'lastFedTimestamp': Timestamp.fromDate(fedTime),
        };

        async.elapse(const Duration(hours: 25));
        
        final currentState = service.determineCurrentFieryState(fedUserData);
        expect(currentState, 'NOT_FED');
      });
    });

    test('after 49 hours, state should be DEAD', () {
      fakeAsync((async) {
        final firestore = FakeFirebaseFirestore();
        final fedTime = DateTime(2024, 1, 1, 10, 0);
        final clock = Clock.fixed(fedTime);
        final service = PetService(firestore: firestore, auth: auth, clock: clock);

        final fedUserData = {
          'fieryState': 'FED',
          'streakCount': 5,
          'lastFedTimestamp': Timestamp.fromDate(fedTime),
        };
        
        async.elapse(const Duration(hours: 49));
        
        final currentState = service.determineCurrentFieryState(fedUserData);
        expect(currentState, 'DEAD');
      });
    });
  });
}