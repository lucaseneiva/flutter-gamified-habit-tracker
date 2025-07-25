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
          return const Scaffold(
            body: Center(child: Text("Criando seu bichinho...")),
          );
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
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetIndicators(int petCount) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Informação do pet atual
          Text(
            "Pet ${_currentPetIndex + 1} de $petCount",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 16),
          
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
    );
  }

  Widget _buildSinglePetScreen(dynamic pet) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildPetPage(pet),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildPetPage(dynamic pet) {
    final PetService petService = ref.read(petServiceProvider);
    var currentState = petService.determineCurrentFiryState(pet);

    // Lógica para resetar pet morto
    if (currentState.isDead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        petService.resetPetIfDead(pet.petid!);
      });
    }

    int streakCount = (currentState.isDead) ? 0 : (pet.streakCount ?? 0);

    Widget speechBubbleWidget = _buildSpeechBubble(currentState);

    return Center(
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
              petService.feedPet(pet.petid);
            },
          ),
          Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(dynamic currentState) {
    if (currentState.isFed) {
      // Pet está alimentado, busca a frase da API
      final quoteAsync = ref.watch(randomQuoteProvider);
      return quoteAsync.when(
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
      return SpeechBubble(
        message: 'Estou com fome!',
        bubbleColor: Colors.white,
        borderColor: const Color(0xFFE0E0E0),
        textColor: const Color(0xFF4F4F4F),
      );
    } else {
      // Nenhum balão para outros estados (morto, etc.)
      return const SizedBox.shrink();
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateHabitScreen()),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}