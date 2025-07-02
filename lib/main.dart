import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/utils/decision_screen.dart'; // Importa a tela de decisão
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Mudei para false para produção
      title: 'Firy Streak',
      theme: AppTheme.lightTheme,
      home:
          const DecisionScreen(), // AQUI: Nosso ponto de entrada para autenticação
    );
  }
}
