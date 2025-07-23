// lib/pet_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clock/clock.dart'; // Importe o pacote clock
import 'package:firy_streak/features/pet_management/domain/pet_state.dart';

class PetService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Clock _clock; // Injetando o relógio!

  PetService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required Clock clock,
  }) : _firestore = firestore,
       _auth = auth,
       _clock = clock;

  User? get _currentUser => _auth.currentUser;

  // Stream que a UI vai ouvir para obter os dados do usuário
  Stream<DocumentSnapshot> get petDataStream {
    if (_currentUser == null) {
      // Retorna um stream vazio se não houver usuário
      return Stream.empty();
    }
    return _firestore.collection('users').doc(_currentUser!.uid).snapshots();
  }

  Future<void> setHabit(String habitName) async {
    if (_currentUser == null) return;
    final docRef = _firestore.collection('users').doc(_currentUser!.uid);
    await docRef.update({'habitName': habitName});
  }

  Future<void> feedPet() async {
    if (_currentUser == null) return;
    final docRef = _firestore.collection('users').doc(_currentUser!.uid);

    await docRef.update({
      'lastFedTimestamp': Timestamp.fromDate(_clock.now()),
      'streakCount': FieldValue.increment(1),
    });
  }

  PetState determineCurrentFiryState(Map<String, dynamic> userData) {
    final Timestamp? lastFedTimestamp = userData['lastFedTimestamp'];
    final int streak = userData['streakCount'] ?? 0;

    // Isso serve como um fallback seguro.
    if (lastFedTimestamp == null) {
      return PetState(GrowthStage.baby, FeedingStatus.notFed);
    }

    final lastFedDate = lastFedTimestamp.toDate();
    final now = _clock.now(); // Usa o relógio injetado!

    // Lógica de tempo crucial
    final difference = now.difference(lastFedDate);

    if (difference.inDays >= 2) {
      // Passaram-se 2 dias ou mais desde a última alimentação
      return PetState(GrowthStage.dead);
    }

    // Determina o status da alimentação
    final feedingStatus = difference.inDays >= 1
        ? FeedingStatus.notFed
        : FeedingStatus.fed;

    // Determina o estágio de crescimento com base na streak
    GrowthStage growthStage;
    // Streak thresholds: 1-9 (Baby), 10-29 (Child), 30-59 (Teen), 60+ (Adult)
    if (streak >= 60) {
      growthStage = GrowthStage.adult;
    } else if (streak >= 30) {
      growthStage = GrowthStage.teen;
    } else if (streak >= 10) {
      growthStage = GrowthStage.child;
    } else {
      growthStage = GrowthStage.baby;
    }

    return PetState(growthStage, feedingStatus);
  }

  // Lógica de reset do pet
  Future<void> resetPetIfDead() async {
    if (_currentUser == null) return;
    final docRef = _firestore.collection('users').doc(_currentUser!.uid);
    await docRef.update({'streakCount': 0});
  }
}
