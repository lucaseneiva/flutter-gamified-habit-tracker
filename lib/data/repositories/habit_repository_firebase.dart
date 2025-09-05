import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clock/clock.dart';
import 'package:firy_streak/domain/models/habit.dart';
import 'package:firy_streak/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository{
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HabitRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required Clock clock,
  }) : _firestore = firestore,
       _auth = auth;

  User? get _currentUser => _auth.currentUser;

  @override
  Future<Habit?> getHabit(String habitId) async {
    if (_currentUser == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('pets')
        .doc(habitId)
        .get();

    if (!doc.exists) return null;

    return Habit.fromJson(doc.data()!, doc.id);
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
  Stream<List<Habit>> get habitDataStream {
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
            return Habit.fromJson(doc.data(), doc.id);
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
  Future<void> createHabit(String habitName) async {
    if (_currentUser == null) return;

    final userId = _auth.currentUser!.uid;

    final newPetDoc = Habit(
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

