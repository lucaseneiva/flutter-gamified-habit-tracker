import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firy_streak/features/auth/domain/user_model.dart';

class AuthService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuthService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  Future<void> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
		final newUserDoc = UserModel(uid: user.uid, email: user.email!, petStatus: 'EGG', streakCount: 0);

        await _firestore.collection('users').doc(user.uid).set(newUserDoc.toJson());
      }
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
