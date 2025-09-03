import 'package:firy_streak/domain/models/habit.dart';
import 'package:firy_streak/domain/models/pet_state.dart';

abstract class HabitRepository {
  Stream<List<HabitEntity>> get habitDataStream;
  Future<void> setHabit(String habitName);
  Future<void> checkIn(habitId);
  Future<void> createHabit(String habitName);
  PetState determineCurrentPetState(HabitEntity habitEntity);
  Future<void> resetHabit(String habitId);
  Future<void> deleteHabit(String habitId);
}