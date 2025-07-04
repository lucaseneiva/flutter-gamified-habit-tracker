import 'package:firy_streak/features/pet_management/application/pet_providers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    final petDataAsync = ref.watch(petDataStreamProvider);

    
    return petDataAsync.when(
      data: (snapshot) {
        var userData = snapshot.data() as Map<String, dynamic>;

        if (!snapshot.exists || snapshot.data() == null) {
          return const Scaffold(
            body: Center(child: Text("Criando seu bichinho...")),
          );
        }

        final String? habitName = userData['habitName'];

        if (habitName == null || habitName.isEmpty) {
          return const CreateHabitScreen();
        }

        final petService = ref.read(petServiceProvider);
        var currentState = petService.determineCurrentFiryState(userData);

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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("Ocorreu um erro: $err"))),
    );
  }
}
