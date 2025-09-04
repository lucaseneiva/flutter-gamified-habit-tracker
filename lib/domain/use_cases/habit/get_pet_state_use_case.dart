import 'package:clock/clock.dart';
import 'package:firy_streak/domain/models/habit.dart';
import 'package:firy_streak/domain/models/pet_state.dart';

class GetPetStateUseCase {
  final Clock _clock;

  GetPetStateUseCase({required Clock clock}) : _clock = clock;

  
  PetState execute(Habit habit) {
    if (habit.lastCheckInTimestamp == null) {
      return PetState(GrowthStage.baby, FeedingStatus.notFed);
    }

    final lastFedDate = habit.lastCheckInTimestamp!.toDate();
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
    if (habit.streakCount! >= 60) {
      growthStage = GrowthStage.adult;
    } else if (habit.streakCount! >= 30) {
      growthStage = GrowthStage.teen;
    } else if (habit.streakCount! >= 10) {
      growthStage = GrowthStage.child;
    } else {
      growthStage = GrowthStage.baby;
    }

    return PetState(growthStage, feedingStatus);
  }
}