// lib/decision_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firy_streak/features/pet_management/presentation/onboarding_screen.dart';
import 'package:firy_streak/core/auth/auth_gate.dart';

class DecisionScreen extends StatefulWidget {
  const DecisionScreen({super.key});

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // A chave 'onboarding_complete' será true se o usuário já viu o tutorial.
    // O '?? false' garante que se a chave não existir, o valor será false.

    // final bool hasSeenOnboarding = prefs.getBool('onboarding_complete') ?? false;

    final bool hasSeenOnboarding = false;

    // Aguarda um pequeno instante para evitar um flash de tela
    await Future.delayed(const Duration(milliseconds: 50));

    if (mounted) {
      if (hasSeenOnboarding) {
        // Se já viu, vai direto para a verificação de login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      } else {
        // Se nunca viu, mostra o onboarding
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tela de carregamento simples enquanto a decisão é feita
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
