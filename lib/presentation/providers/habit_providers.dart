import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firy_streak/domain/models/habit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/habit_repository_impl.dart';

final habitRepositoryImplProvider = Provider<HabitRepositoryImpl>((ref) {
  return HabitRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    clock: const Clock(),
  );
});

final petDataStreamProvider = StreamProvider.autoDispose<List<HabitEntity>>((ref) {
  final habitRepositoryImpl = ref.watch(habitRepositoryImplProvider);

  return habitRepositoryImpl.habitDataStream;
});