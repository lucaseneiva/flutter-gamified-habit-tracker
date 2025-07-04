import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pet_service.dart';

final petServiceProvider = Provider<PetService>((ref) {
  return PetService(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    clock: const Clock(),
  );
});

final petDataStreamProvider = StreamProvider.autoDispose<DocumentSnapshot>((ref) {
  final petService = ref.watch(petServiceProvider);

  return petService.petDataStream;
});