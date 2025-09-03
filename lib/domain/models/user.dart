import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;

  const UserModel({
    required this.uid,
    required this.email,
  });

  // Um construtor "vazio"
  factory UserModel.empty() {
    return const UserModel(
      uid: '',
      email: '',
    );
  }

  /// Converte um documento do Firestore (Map) em um objeto UserModel.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
    );
  }

  /// Converte um objeto UserModel em um Map para ser salvo no Firestore.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
    };
  }

  // Necessário para o Equatable
  @override
  List<Object?> get props => [
    uid,
    email,
  ];
}
