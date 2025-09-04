import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firy_streak/domain/models/habit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/habit_repository_firebase.dart';
import 'package:firy_streak/domain/use_cases/habit/check_in_habit_use_case.dart';
import 'package:firy_streak/domain/use_cases/habit/get_pet_state_use_case.dart';

final habitRepositoryImplProvider = Provider<HabitRepositoryImpl>((ref) {
  return HabitRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    clock: const Clock(),
  );
});

final petDataStreamProvider = StreamProvider.autoDispose<List<Habit>>((ref) {
  final habitRepositoryImpl = ref.watch(habitRepositoryImplProvider);

  return habitRepositoryImpl.habitDataStream;
});

final checkInUseCaseProvider = Provider<CheckInHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryImplProvider);
  return CheckInHabitUseCase(repository, Clock());
});

final getPetStateUseCaseProvider = Provider<GetPetStateUseCase>((ref) {
  return GetPetStateUseCase(clock: Clock());
});