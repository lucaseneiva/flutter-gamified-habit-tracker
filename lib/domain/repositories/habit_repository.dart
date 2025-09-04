import 'package:firy_streak/domain/models/habit.dart';
import 'package:firy_streak/domain/models/pet_state.dart';

abstract class HabitRepository {
  Stream<List<HabitEntity>> get habitDataStream;
  Future<void> createHabit(String habitName);
  Future<HabitEntity?> getHabit(String habit);
  Future<void> updateHabit(String habitId, Map<String, dynamic> updates);
  Future<void> deleteHabit(String habitId);

  //legacy
  Future<void> setHabit(String habitName);
  Future<void> checkIn(habitId);
  PetState determineCurrentPetState(HabitEntity habitEntity);
  Future<void> resetHabit(String habitId);
}