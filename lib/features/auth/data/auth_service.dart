import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        // 2. CRIA O DOCUMENTO NO FIRESTORE!
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'petStatus': 'EGG',
          'streakCount': 0,
          'lastFedTimestamp':
              null, // Começa nulo, pois ainda não foi alimentado
          'habitName': null,
        });
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
