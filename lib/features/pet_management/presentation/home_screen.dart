import 'package:firy_streak/core/theme/app_colors.dart';
import 'package:firy_streak/features/pet_management/application/pet_providers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/streak_card.dart';
import 'create_habit_screen.dart'; // Importa a tela de criação de hábito
import 'package:firy_streak/features/pet_management/presentation/widgets/pet_display.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firy_streak/features/pet_management/presentation/widgets/speech_bubble.dart';
import 'package:firy_streak/features/quotes/application/quote_provider.dart';

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

        Widget speechBubbleWidget;
        if (currentState.isFed) {
          // Pet está alimentado, busca a frase da API
          final quoteAsync = ref.watch(randomQuoteProvider);
          speechBubbleWidget = quoteAsync.when(
            data: (quote) => SpeechBubble(
              message: quote,
              bubbleColor: Colors.white,
              borderColor: const Color(0xFFE0E0E0),
              textColor: const Color(0xFF4F4F4F),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SpeechBubble(message: 'Você é demais!'),
          );
        } else if (currentState.isHungry || currentState.isEgg) {
          // Pet com fome ou ovo, mostra mensagem padrão
          speechBubbleWidget = SpeechBubble(
            message: currentState.isHungry ? 'Estou com fome!' : 'Me choca!',
            bubbleColor: Colors.white,
            borderColor: const Color(0xFFE0E0E0),
            textColor: const Color(0xFF4F4F4F),
          );
        } else {
          // Nenhum balão para outros estados (morto, etc.)
          speechBubbleWidget = const SizedBox.shrink();
        }

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(border: Border(
                bottom: BorderSide(color: AppColors.lightGrey,
                width: 4)
              )),
              child: AppBar(
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
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 1),
                StreakCard(streakCount: streakCount),
                Spacer(flex: 1),
                  speechBubbleWidget,
                SizedBox(height: 16),
                PetDisplay(
                  petState: currentState,
                  onFeedPet: petService.feedPet,
                ),
                Spacer(flex: 1)
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
