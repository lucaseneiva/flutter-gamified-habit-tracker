import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String petStatus;
  final int streakCount;
  final Timestamp? lastFedTimestamp;
  final String? habitName;

  const UserModel({
    required this.uid,
    required this.email,
    required this.petStatus,
    required this.streakCount,
    this.lastFedTimestamp,
    this.habitName,
  });

  // Um construtor "vazio"
  factory UserModel.empty() {
    return const UserModel(
      uid: '',
      email: '',
      petStatus: 'EGG',
      streakCount: 0,
    );
  }

  /// Converte um documento do Firestore (Map) em um objeto UserModel.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      petStatus: json['petStatus'] as String,
      streakCount: json['streakCount'] as int,
      lastFedTimestamp: json['lastFedTimestamp'] as Timestamp?,
      habitName: json['habitName'] as String?,
    );
  }

  /// Converte um objeto UserModel em um Map para ser salvo no Firestore.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'petStatus': petStatus,
      'streakCount': streakCount,
      'lastFedTimestamp': lastFedTimestamp,
      'habitName': habitName,
    };
  }

  // Necessário para o Equatable
  @override
  List<Object?> get props => [
    uid,
    email,
    petStatus,
    streakCount,
    lastFedTimestamp,
    habitName,
  ];
}
