// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:firy_streak/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // O tema claro é o único que teremos por enquanto
  static final ThemeData lightTheme = ThemeData(
    
    
    // Esquema de Cores principal

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.primaryDark,
      surface: AppColors.background,
      error: AppColors.error,
    ),

    // Cor de fundo padrão dos Scaffolds
    scaffoldBackgroundColor: AppColors.background,

    // Tema da AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: AppColors.textDark,
      ),
    ),

    // Tema de Texto
    textTheme: GoogleFonts.nunitoSansTextTheme(
      const TextTheme(
        // Ex: Usado em 'Qual hábito você quer criar?'
        displayLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark, fontSize: 32), 
        // Ex: Usado em 'Crie sua conta'
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 24),
        // Ex: Usado nas descrições do onboarding
        bodyLarge: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkGrey, fontSize: 18),
        // Ex: Usado em labels e textos comuns
        bodyMedium: TextStyle(fontWeight: FontWeight.normal, color: AppColors.darkGrey, fontSize: 16),
      ),
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.blue
    ),
    // Tema dos Botões Elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.nunitoSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Tema dos Campos de Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
         fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.blue, width: 2.0),
      ),
      floatingLabelStyle: TextStyle(color: AppColors.blue),
      
    ),
    
    // Tema do TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blue,
        textStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w600),
      ),
    )
  );
}