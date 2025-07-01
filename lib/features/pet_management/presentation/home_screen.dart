// lib/home_screen.dart
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/pet_service.dart'; // Importe o novo serviço
import 'widgets/streak_card.dart';
import 'create_habit_screen.dart'; // Importa a tela de criação de hábito
import 'package:firy_streak/features/pet_management/presentation/widgets/pet_display.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Crie uma instância do serviço. No app real, usamos o clock padrão.
  late final PetService _petService;

  @override
  void initState() {
    super.initState();
    _petService = PetService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      clock: const Clock(), // Aqui usamos o relógio real!
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _petService.petDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Ocorreu um erro!")));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("Criando seu bichinho...")));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;

		final String? habitName = userData['habitName'];

		if (habitName == null || habitName.isEmpty) {
          // Se o usuário ainda não definiu um hábito, mostra a tela de criação.
          return const CreateHabitScreen();
        }
		
        // A lógica de estado agora vem do serviço
        var currentState = _petService.determineCurrentFieryState(userData);

        // Se o pet morreu, atualizamos o streak no banco
        if (currentState == 'DEAD' && userData['fieryState'] != 'DEAD') {
           WidgetsBinding.instance.addPostFrameCallback((_) {
              _petService.resetPetIfDead();
           });
        }
        
        int streakCount = (currentState == 'DEAD') ? 0 : (userData['streakCount'] ?? 0);

        return Scaffold(
          appBar: AppBar(title: const Text("Meu Firy Streak")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Simplesmente centralizamos o card sem forçar largura
                StreakCard(streakCount: streakCount,),
                const SizedBox(height: 20),
                PetDisplay(petState: currentState, onFeedPet: _petService.feedPet,)
                
              ],
            ),
          ),
        );
      },
    );

  }
  
}
