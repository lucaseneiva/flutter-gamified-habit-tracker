import 'package:firy_streak/presentation/core/app_colors.dart';
import 'package:firy_streak/presentation/providers/auth_providers.dart';
import 'package:firy_streak/presentation/providers/habit_providers.dart';
import 'package:firy_streak/data/repositories/habit_repository_firebase.dart';
import 'package:firy_streak/domain/models/habit.dart';
import 'package:firy_streak/presentation/habit/widgets/habit_name_card.dart';
import 'package:flutter/material.dart';
import 'widgets/streak_card.dart';
import 'create_habit_screen.dart';
import 'package:firy_streak/presentation/habit/widgets/pet_display.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firy_streak/presentation/habit/widgets/speech_bubble.dart';
import 'package:firy_streak/presentation/providers/quote_providers.dart';
import 'package:firy_streak/presentation/core/utils/confirmation_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:firy_streak/routing/routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  int _currentPetIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petDataAsync = ref.watch(petDataStreamProvider);

    return petDataAsync.when(
      data: (snapshot) {
        if (snapshot.isEmpty) {
          return const Scaffold(body: CreateHabitScreen());
        }

        // Se só tem um pet, não precisa do PageView
        if (snapshot.length == 1) {
          return _buildSinglePetScreen(snapshot.first);
        }

        return Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // Indicadores de pets
              _buildPetIndicators(snapshot.length),

              // PageView com os pets
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPetIndex = index;
                    });
                  },
                  itemCount: snapshot.length,
                  itemBuilder: (context, index) {
                    return _buildPetPage(snapshot[index]);
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("Ocorreu um erro: $err"))),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.lightGrey, width: 4),
          ),
        ),
        child: AppBar(
          title: const Text("Chaminhas"),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu), // Ícone do hambúrger
              onSelected: (String value) {
                switch (value) {
                  case 'delete_pet':
                    _showDeletePetDialog();
                    break;
                  case 'logout':
                    _showLogoutDialog();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'delete_pet',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.darkGrey),
                      SizedBox(width: 8),
                      Text('Excluir Chaminha'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Sair'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletePetDialog() {
    final petDataAsync = ref.read(petDataStreamProvider);

    petDataAsync.whenData((pets) {
      if (pets.isEmpty) return;

      final currentPet = pets[_currentPetIndex];

      showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
          title: "Excluir Chaminha",
          message:
              "Tem certeza que deseja excluir a Chaminha '${currentPet.habitName}'? Esta ação não pode ser desfeita.",
          onConfirmation: () async {
            // Salva referências antes das operações async
            final navigator = Navigator.of(context);
            final scaffoldMessenger = ScaffoldMessenger.of(context);

            try {
              final HabitRepositoryImpl habitRepository = ref.read(
                habitRepositoryImplProvider,
              );
              await habitRepository.deleteHabit(currentPet.habitId!);

              // Mostra mensagem de sucesso usando a referência salva
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Chaminha "${currentPet.habitName}" excluído com sucesso!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              // Usa a referência salva do navigator
              navigator.pop();

              // Mostra mensagem de erro usando a referência salva
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Erro ao excluir Chaminha: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      );
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: "Logout",
        message: "Tem certeza que quer fazer o Logout?",
        onConfirmation: () async {
          final authRepository = ref.read(authRepositoryProvider);
          try {
            await authRepository.signOut();
          } catch (e) {
            // fazer depois 
          }
        },
      ),
    );
  }

  Widget _buildPetIndicators(int petCount) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            // Informação do pet atual
            "Chaminha ${_currentPetIndex + 1} de $petCount",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Indicadores visuais
              ...List.generate(
                petCount,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPetIndex == index
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePetScreen(Habit pet) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildPetPage(pet),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildPetPage(Habit pet) {
    final HabitRepositoryImpl habitRepository = ref.read(
      habitRepositoryImplProvider,
    );
    final getPetState = ref.read(getPetStateUseCaseProvider);
    var currentState = getPetState.execute(pet);

    // Lógica para resetar pet morto
    if (currentState.isDead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        habitRepository.resetHabit(pet.habitId!);
      });
    }

    int streakCount = (currentState.isDead) ? 0 : (pet.streakCount ?? 0);

    Widget speechBubbleWidget = _buildSpeechBubble(currentState);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(flex: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: HabitNameCard(habitName: pet.habitName!)),

                Expanded(child: StreakCard(streakCount: streakCount)),
              ],
            ),
          ),
          Spacer(flex: 1),

          speechBubbleWidget,
          PetDisplay(
            petState: currentState,
            onCheckIn: () {
              final habitId = pet.habitId ?? '';
              if (habitId.isNotEmpty) {
                ref.read(checkInUseCaseProvider).call(habitId);
              } else {
                print('❌ Erro: habitId está vazio!');
              }
            },
          ),
          Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(dynamic currentState) {
    if (currentState.isJustFed) {
      // Pet está alimentado, busca a frase da API
      final quoteAsync = ref.watch(randomQuoteProvider);
      return quoteAsync.when(
        data: (quote) => SpeechBubble(
          message: quote.text,
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
      return SpeechBubble(
        message: 'Estou com fome!',
        bubbleColor: Colors.white,
        borderColor: const Color(0xFFE0E0E0),
        textColor: const Color(0xFF4F4F4F),
      );
    } else if (currentState.isFed) {
      return SpeechBubble(
        message: 'Barriguinha cheia!',
        bubbleColor: Colors.white,
        borderColor: const Color(0xFFE0E0E0),
        textColor: const Color(0xFF4F4F4F),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        context.push(AppRoutes.createHabit);
      },
      child: const Icon(Icons.add),
    );
  }
}
