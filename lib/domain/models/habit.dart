import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  final String? habitId;
  final int? streakCount;
  final Timestamp? lastCheckInTimestamp;
  final String? habitName;

  const Habit({
    this.streakCount,
    this.habitId,
    this.lastCheckInTimestamp,
    this.habitName,
  });

  factory Habit.empty() {
    return const Habit(streakCount: 0);
  }

  factory Habit.fromJson(Map<String, dynamic> json, String docId) {
    return Habit(
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
