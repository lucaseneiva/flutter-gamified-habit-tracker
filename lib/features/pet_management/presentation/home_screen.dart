import 'package:firy_streak/core/theme/app_colors.dart';
import 'package:firy_streak/features/pet_management/application/pet_providers.dart';
import 'package:firy_streak/features/pet_management/data/pet_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/streak_card.dart';
import 'create_habit_screen.dart';
import 'package:firy_streak/features/pet_management/presentation/widgets/pet_display.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firy_streak/features/pet_management/presentation/widgets/speech_bubble.dart';
import 'package:firy_streak/features/quotes/application/quote_provider.dart';
import 'package:firy_streak/core/utils/confirmation_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final petDataAsync = ref.watch(petDataStreamProvider);

    return petDataAsync.when(
      data: (snapshot) {
        if (snapshot.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Criando seu bichinho...")),
          );
        }
        final PetService petService = ref.read(petServiceProvider);

        if (snapshot.isEmpty) {
          return const CreateHabitScreen();
        }

        var currentState = petService.determineCurrentFiryState(snapshot.first);

        if (currentState.isDead) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            petService.resetPetIfDead();
          });
        }

        int streakCount = (currentState.isDead)
            ? 0
            : (snapshot.first.streakCount ?? 0);

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
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => SpeechBubble(message: 'Você é demais!'),
          );
        } else if (currentState.isHungry) {
          speechBubbleWidget = SpeechBubble(
            message: 'Estou com fome!',
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
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.lightGrey, width: 4),
                ),
              ),
              child: AppBar(
                title: const Text("Meu Firy"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Sair',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: "Logout",
                        message: "Tem certeza que quer fazer o Logout?",
                        onConfirmation: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pop;
                        },
                      ),
                    ),
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
                  onFeedPet: () {
                    petService.feedPet(snapshot.first.petid);
                  },
                ),
                Spacer(flex: 1),
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
