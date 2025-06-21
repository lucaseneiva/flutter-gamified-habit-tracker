// lib/home_screen.dart
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pet_service.dart'; // Importe o novo serviço
import 'widgets/speech_bubble.dart';
import 'widgets/streak_card.dart';

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
      height: 240, // Altura total para acomodar pet + bubble
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
                  // O botão é habilitado para reviver o pet ou alimentá-lo
                  onPressed: (currentState == 'NOT_FED' || currentState == 'EGG' || currentState == 'DEAD')
                      ? () => _petService.feedPet()
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
    switch (state) {
      case 'EGG': svgAssetPath = 'assets/egg.svg'; break;
      case 'FED': svgAssetPath = 'assets/fed.svg'; break;

      case 'NOT_FED': svgAssetPath = 'assets/not_fed.svg'; break;
      case 'DEAD': svgAssetPath = 'assets/dead.svg'; break;
      default: svgAssetPath = 'assets/egg.svg';
    }
    return SvgPicture.asset(svgAssetPath, height: 200,);
  }

  
}
