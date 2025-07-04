import 'package:firy_streak/features/pet_management/application/pet_providers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/streak_card.dart';
import 'create_habit_screen.dart'; // Importa a tela de criação de hábito
import 'package:firy_streak/features/pet_management/presentation/widgets/pet_display.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Crie uma instância do serviço. No app real, usamos o clock padrão.

  @override
  Widget build(BuildContext context) {
    final petService = ref.watch(petServiceProvider);

    return StreamBuilder<DocumentSnapshot>(
      stream: petService.petDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Ocorreu um erro!")));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Criando seu bichinho...")),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;

        final String? habitName = userData['habitName'];

        if (habitName == null || habitName.isEmpty) {
          // Se o usuário ainda não definiu um hábito, mostra a tela de criação.
          return const CreateHabitScreen();
        }

        // A lógica de estado agora vem do serviço
        var currentState = petService.determineCurrentFiryState(userData);

        // Se o pet morreu, atualizamos o streak no banco
        if (currentState.isDead) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            petService.resetPetIfDead();
          });
        }

        int streakCount = (currentState.isDead)
            ? 0
            : (userData['streakCount'] ?? 0);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Meu Firy Streak"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Simplesmente centralizamos o card sem forçar largura
                StreakCard(streakCount: streakCount),
                const SizedBox(height: 20),
                PetDisplay(
                  petState: currentState,
                  onFeedPet: petService.feedPet,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
