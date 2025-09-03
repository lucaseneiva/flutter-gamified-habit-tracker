import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firy_streak/data/repositories/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authIsLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  return AuthService(auth: auth, firestore: firestore);
});
