// lib/pet_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clock/clock.dart'; // Importe o pacote clock
import 'package:firy_streak/features/habit_management/domain/pet_state.dart';
import 'package:firy_streak/features/habit_management/domain/habit_entity.dart';

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
  Stream<List<PetModel>> get petDataStream {
    if (_auth.currentUser == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('pets')
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((doc) {
            return PetModel.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> setHabit(String habitName) async {
    if (_currentUser == null) return;
    final docRef = _firestore.collection('users').doc(_currentUser!.uid);
    await docRef.update({'habitName': habitName});
  }

  Future<void> feedPet(petId) async {
    if (_currentUser == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId);

    await docRef.update({
      'lastFedTimestamp': Timestamp.fromDate(_clock.now()),
      'streakCount': FieldValue.increment(1),
    });
  }

  Future<void> createPet(String habitName) async {
    if (_currentUser == null) return;

    final userId = _auth.currentUser!.uid;

    final newPetDoc = PetModel(
      habitName: habitName,
      streakCount: 0,
      lastFedTimestamp: null,
    );

    final petRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(); // gera ID automático

    await petRef.set(newPetDoc.toJson());
  }

  PetState determineCurrentFiryState(PetModel petModel) {
    if (petModel.lastFedTimestamp == null) {
      return PetState(GrowthStage.baby, FeedingStatus.notFed);
    }

    final lastFedDate = petModel.lastFedTimestamp!.toDate();
    final now = _clock.now();

    // Calcula o início do dia da última alimentação (00:00:00)
    final lastFedDayStart = DateTime(
      lastFedDate.year,
      lastFedDate.month,
      lastFedDate.day,
    );

    // Calcula o início do dia atual (00:00:00)
    final todayStart = DateTime(now.year, now.month, now.day);

    // Calcula a diferença em dias entre os inícios dos dias
    final daysDifference = todayStart.difference(lastFedDayStart).inDays;

    if (daysDifference >= 2) {
      // Passaram-se 2 dias ou mais desde a última alimentação - pet morreu
      return PetState(GrowthStage.dead);
    }

    // Determina o status da alimentação baseado nos dias
    late FeedingStatus feedingStatus;
    if (now.difference(lastFedDate).inSeconds <= 10) {
      feedingStatus = FeedingStatus.justFed;
    } else if (daysDifference >= 1) {
      feedingStatus = FeedingStatus.notFed;
    } else {
      feedingStatus = FeedingStatus.fed;
    }

    // Determina o estágio de crescimento com base na streak
    GrowthStage growthStage;
    // Streak thresholds: 1-9 (Baby), 10-29 (Child), 30-59 (Teen), 60+ (Adult)
    if (petModel.streakCount! >= 60) {
      growthStage = GrowthStage.adult;
    } else if (petModel.streakCount! >= 30) {
      growthStage = GrowthStage.teen;
    } else if (petModel.streakCount! >= 10) {
      growthStage = GrowthStage.child;
    } else {
      growthStage = GrowthStage.baby;
    }

    return PetState(growthStage, feedingStatus);
  }

  // Lógica de reset do pet
  Future<void> resetPetIfDead(String petId) async {
    if (_currentUser == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(petId);
    await docRef.update({'streakCount': 0});
  }

  Future<void> deletePet(String petId) async {
    if (_currentUser == null) return;

    try {
      final docRef = _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('pets')
          .doc(petId);

      await docRef.delete();
    } catch (e) {
      throw Exception('Erro ao excluir pet: $e');
    }
  }
}

