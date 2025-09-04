import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clock/clock.dart';
import 'package:firy_streak/domain/models/pet_state.dart';
import 'package:firy_streak/domain/models/habit.dart';
import 'package:firy_streak/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository{
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Clock _clock;

  HabitRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required Clock clock,
  }) : _firestore = firestore,
       _auth = auth,
       _clock = clock;

  User? get _currentUser => _auth.currentUser;

  @override
  Future<HabitEntity?> getHabit(String habitId) async {
    if (_currentUser == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(habitId)
        .get();

    if (!doc.exists) return null;

    return HabitEntity.fromJson(doc.data()!, doc.id);
  }

  @override
  Future<void> updateHabit(String habitId, Map<String, dynamic> updates) async {
    if (_currentUser == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(habitId);

    await docRef.update(updates);
  }
  
  @override
  Stream<List<HabitEntity>> get habitDataStream {
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
            return HabitEntity.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Future<void> setHabit(String habitName) async {
    if (_currentUser == null) return;
    final docRef = _firestore.collection('users').doc(_currentUser!.uid);
    await docRef.update({'habitName': habitName});
  }

  @override
  Future<void> checkIn(habitId) async {
    if (_currentUser == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(habitId);

    await docRef.update({
      'lastCheckInTimestamp': Timestamp.fromDate(_clock.now()),
      'streakCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> createHabit(String habitName) async {
    if (_currentUser == null) return;

    final userId = _auth.currentUser!.uid;

    final newPetDoc = HabitEntity(
      habitName: habitName,
      streakCount: 0,
      lastCheckInTimestamp: null,
    );

    final petRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc();

    await petRef.set(newPetDoc.toJson());
  }

  @override
  PetState determineCurrentPetState(HabitEntity habitEntity) {
    if (habitEntity.lastCheckInTimestamp == null) {
      return PetState(GrowthStage.baby, FeedingStatus.notFed);
    }

    final lastFedDate = habitEntity.lastCheckInTimestamp!.toDate();
    final now = _clock.now();

    final lastFedDayStart = DateTime(
      lastFedDate.year,
      lastFedDate.month,
      lastFedDate.day,
    );

    final todayStart = DateTime(now.year, now.month, now.day);

    final daysDifference = todayStart.difference(lastFedDayStart).inDays;

    if (daysDifference >= 2) {
      return PetState(GrowthStage.dead);
    }

    late FeedingStatus feedingStatus;
    if (now.difference(lastFedDate).inSeconds <= 10) {
      feedingStatus = FeedingStatus.justFed;
    } else if (daysDifference >= 1) {
      feedingStatus = FeedingStatus.notFed;
    } else {
      feedingStatus = FeedingStatus.fed;
    }

    GrowthStage growthStage;
    if (habitEntity.streakCount! >= 60) {
      growthStage = GrowthStage.adult;
    } else if (habitEntity.streakCount! >= 30) {
      growthStage = GrowthStage.teen;
    } else if (habitEntity.streakCount! >= 10) {
      growthStage = GrowthStage.child;
    } else {
      growthStage = GrowthStage.baby;
    }

    return PetState(growthStage, feedingStatus);
  }

  @override
  Future<void> resetHabit(String habitId) async {
    if (_currentUser == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(habitId);
    await docRef.update({'streakCount': 0});
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    if (_currentUser == null) return;

    try {
      final docRef = _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('pets')
          .doc(habitId);

      await docRef.delete();
    } catch (e) {
      throw Exception('Erro ao excluir pet: $e');
    }
  }
}

