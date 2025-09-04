import 'package:firy_streak/domain/models/habit.dart';

abstract class HabitRepository {
  Stream<List<Habit>> get habitDataStream;
  Future<void> createHabit(String habitName);
  Future<Habit?> getHabit(String habit);
  Future<void> updateHabit(String habitId, Map<String, dynamic> updates);
  Future<void> deleteHabit(String habitId);

  //legacy
  Future<void> setHabit(String habitName);
  Future<void> resetHabit(String habitId);
}