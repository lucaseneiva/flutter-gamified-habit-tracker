// lib/home_screen.dart
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pet_service.dart'; // Importe o novo serviço

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
                _buildPetImage(currentState),
                const SizedBox(height: 20),
                Text("Streak: $streakCount"),
                const SizedBox(height: 40),
                ElevatedButton(
                  // O botão é habilitado para reviver o pet ou alimentá-lo
                  onPressed: (currentState == 'NOT_FED' || currentState == 'EGG' || currentState == 'DEAD')
                      ? () => _petService.feedPet()
                      : null,
                  child: Text(currentState == 'DEAD' ? "Reviver o Bichinho" : "Alimentar o Bichinho"),
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