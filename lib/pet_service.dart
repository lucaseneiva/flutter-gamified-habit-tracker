// lib/pet_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clock/clock.dart'; // Importe o pacote clock

class PetService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Clock _clock; // Injetando o relógio!

  PetService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required Clock clock,
  })  : _firestore = firestore,
        _auth = auth,
        _clock = clock;

  User? get _currentUser => _auth.currentUser;

  // Stream que a UI vai ouvir para obter os dados do usuário
  Stream<DocumentSnapshot> get petDataStream {
    if (_currentUser == null) {
      // Retorna um stream vazio se não houver usuário
      return Stream.empty();
    }
    return _firestore.collection('users').doc(_currentUser!.uid).snapshots();
  }

  // Função para ALIMENTAR o pet
  Future<void> feedPet() async {
    if (_currentUser == null) return;
    final docRef = _firestore.collection('users').doc(_currentUser!.uid);

    final doc = await docRef.get();
    // Usa um cast seguro para evitar exceções de runtime
    final data = doc.data();
    final currentStreak = (data?['streakCount'] ?? 0) as int;
    
    // Usa o relógio injetado!
    await docRef.update({
      'fieryState': 'FED',
      'lastFedTimestamp': Timestamp.fromDate(_clock.now()),
      'streakCount': currentStreak + 1,
    });
  }

  // Função para DETERMINAR O ESTADO ATUAL
  String determineCurrentFieryState(Map<String, dynamic> userData) {
    final String savedState = userData['fieryState'] ?? 'EGG';
    final Timestamp? lastFedTimestamp = userData['lastFedTimestamp'];

    if (savedState == 'EGG') {
      return 'EGG';
    }

    if (lastFedTimestamp == null) {
      return 'EGG';
    }

    final lastFedDate = lastFedTimestamp.toDate();
    final now = _clock.now(); // Usa o relógio injetado!

    // Lógica de tempo crucial
    final difference = now.difference(lastFedDate);

    if (difference.inDays >= 2) {
      // Passaram-se 2 dias ou mais desde a última alimentação
      return 'DEAD';
    } else if (difference.inDays >= 1) {
      // Passou 1 dia
      return 'NOT_FED';
    } else {
      // Ainda no mesmo dia da alimentação
      return 'FED';
    }
  }

  // Lógica de reset do pet
  Future<void> resetPetIfDead() async {
    if (_currentUser == null) return;
    final docRef = _firestore.collection('users').doc(_currentUser!.uid);
    await docRef.update({
      'fieryState': 'DEAD', // Mantém como DEAD para mostrar a imagem correta
      'streakCount': 0,
    });
  }
}