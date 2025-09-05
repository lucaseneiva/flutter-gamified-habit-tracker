import 'package:firebase_auth/firebase_auth.dart';
import 'package:firy_streak/domain/repositories/auth_repository.dart';

class AuthRepositoryFirebase implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryFirebase(this._firebaseAuth);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException {
      rethrow; 
    }
  }

  @override
  Future<void> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}