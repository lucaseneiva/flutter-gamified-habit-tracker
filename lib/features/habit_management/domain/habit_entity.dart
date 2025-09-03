import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class HabitEntity extends Equatable {
  final String? habitId;
  final int? streakCount;
  final Timestamp? lastCheckInTimestamp;
  final String? habitName;

  const HabitEntity({
    this.streakCount,
    this.habitId,
    this.lastCheckInTimestamp,
    this.habitName,
  });

  factory HabitEntity.empty() {
    return const HabitEntity(streakCount: 0);
  }

  factory HabitEntity.fromJson(Map<String, dynamic> json, String docId) {
    return HabitEntity(
      habitId: docId,
      streakCount: json['streakCount'] as int?,
      lastCheckInTimestamp: json['lastCheckInTimestamp'] as Timestamp?,
      habitName: json['habitName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streakCount': streakCount,
      'lastCheckInTimestamp': lastCheckInTimestamp,
      'habitName': habitName,
    };
  }
  
  @override
  List<Object?> get props => [
    habitId,
    streakCount,
    lastCheckInTimestamp,
    habitName,
  ];
}
