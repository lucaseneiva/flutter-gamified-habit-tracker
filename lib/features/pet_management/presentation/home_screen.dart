// lib/home_screen.dart
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/pet_service.dart'; // Importe o novo serviço
import 'widgets/speech_bubble.dart';
import 'widgets/streak_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_habit_screen.dart'; // Importa a tela de criação de hábito

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
  
  Widget _buildPetWithBubble(String state) { 
    return SizedBox(
      height: 260, // Altura total para acomodar pet + bubble
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pet image no centro-inferior
          Positioned(
            bottom: 0,
            child: _buildPetImage(state),
          ),
          // Speech bubble no topo, só aparece quando precisa alimentar
          if (state == 'NOT_FED' || state == 'EGG')
            Positioned(
              top: 0,
              child: SpeechBubble(
                message: _getBubbleMessage(state),
                bubbleColor: Colors.white,
                borderColor: const Color(0xFFE0E0E0),
                textColor: const Color(0xFF4F4F4F),
              ),
            ),
        ],
      ),
    );
  }

  String _getBubbleMessage(String state) {
    switch (state) {
      case 'NOT_FED': return 'Estou com fome!';
      case 'EGG': return 'Me choca!';
      default: return '';
    }
  }
  void _showConfirmationDialog(BuildContext context, String currentState) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentState == 'DEAD' ? "✧ Reviver ✧" : "🪵 Alimentar 🪵",
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                currentState == 'DEAD' 
                    ? "Quer mesmo reviver seu companheiro?" 
                    : "Vai dar comida pro bichinho agora?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9703B),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _petService.feedPet();
                    },
                    child: const Text("Confirmar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                _buildPetWithBubble(currentState),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: (currentState == 'NOT_FED' || currentState == 'EGG' || currentState == 'DEAD')
                      ? () => _showConfirmationDialog(context, currentState)
                      : null,
                  child: Text(currentState == 'DEAD' ? "Reviver o Bichinho" : "Alimentar"),
                ),
              ],
            ),
          ),
        );
      },
    );

  }
  
  // A função _buildPetImage pode continuar a mesma
  Widget _buildPetImage(String state) {
    String svgAssetPath;

    if (state.contains('_')) {
      final parts = state.split('_');
      final growthStage = parts[0].toLowerCase(); // baby, child, teen, adult
      final feedingStatus = parts[1].toLowerCase(); // fed, not_fed

      // A primeira fase usa os SVGs antigos para não quebrar o que já existe
      if (growthStage == 'baby') {
        svgAssetPath = 'assets/${feedingStatus == 'fed' ? 'fed' : 'not_fed'}.svg';
      } else {
        // As novas fases usam o padrão "stage_status.svg"
        svgAssetPath = 'assets/${growthStage}_$feedingStatus.svg';
      }
    } else {
      // Lida com os estados simples que não têm estágio (Ovo, Morto)
      switch (state) {
        case 'EGG':
          svgAssetPath = 'assets/egg.svg';
          break;
        case 'DEAD':
          svgAssetPath = 'assets/dead.svg';
          break;
        default:
          // Fallback para qualquer estado inesperado
          svgAssetPath = 'assets/egg.svg';
      }
    }
    return SvgPicture.asset(svgAssetPath, height: 200,);
  }

  
}
