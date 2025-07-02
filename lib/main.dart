import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'auth_gate.dart'; // Vamos criar este arquivo
import 'package:google_fonts/google_fonts.dart';
import 'core/utils/decision_screen.dart'; // Importa a tela de decisão

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
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)
            .copyWith(
              bodyLarge: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w600,
              ), // Negrito
              bodyMedium: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w500,
              ), // Medium
              titleLarge: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w700,
              ), // Extra negrito
            ),

        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          // Estilo para os campos de texto
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          // Estilo para botões
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home:
          const DecisionScreen(), // AQUI: Nosso ponto de entrada para autenticação
    );
  }
}
