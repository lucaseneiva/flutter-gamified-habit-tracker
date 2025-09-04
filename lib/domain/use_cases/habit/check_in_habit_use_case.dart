import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firy_streak/domain/repositories/habit_repository.dart';

class CheckInHabitUseCase {
  final HabitRepository _repository;
  final Clock _clock;

  CheckInHabitUseCase(this._repository, this._clock);

  Future<void> call(String habitId) async {
    final habit = await _repository.getHabit(habitId);
    if (habit == null) {
      throw StateError('Habit not found');
    }

    if (habit.lastCheckInTimestamp != null) {
      final lastCheckIn = habit.lastCheckInTimestamp!.toDate();
      final now = _clock.now();
      
      final lastCheckInDay = DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day);
      final today = DateTime(now.year, now.month, now.day);
      
      if (lastCheckInDay.isAtSameMomentAs(today)) {
        throw StateError('Already checked in today');
      }
    }

    await _repository.updateHabit(habitId, {
      'lastCheckInTimestamp': Timestamp.fromDate(_clock.now()),
      'streakCount': FieldValue.increment(1),
    });
  }
}