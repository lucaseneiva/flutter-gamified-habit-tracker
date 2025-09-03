import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PetModel extends Equatable {
  final String? petid;
  final int? streakCount;
  final Timestamp? lastFedTimestamp;
  final String? habitName;

  const PetModel({
    this.streakCount,
    this.petid,
    this.lastFedTimestamp,
    this.habitName,
  });

  // Um construtor "vazio"
  factory PetModel.empty() {
    return const PetModel(streakCount: 0);
  }

  /// Converte um documento do Firestore (Map) em um objeto PetModel.
  factory PetModel.fromJson(Map<String, dynamic> json, String docId) {
    return PetModel(
      petid: docId,
      streakCount: json['streakCount'] as int?,
      lastFedTimestamp: json['lastFedTimestamp'] as Timestamp?,
      habitName: json['habitName'] as String?,
    );
  }

  /// Converte um objeto PetModel em um Map para ser salvo no Firestore.
  Map<String, dynamic> toJson() {
    return {
      'streakCount': streakCount,
      'lastFedTimestamp': lastFedTimestamp,
      'habitName': habitName,
    };
  }

  // Necessário para o Equatable
  @override
  List<Object?> get props => [
    petid,
    streakCount,
    lastFedTimestamp,
    habitName,
  ];
}
