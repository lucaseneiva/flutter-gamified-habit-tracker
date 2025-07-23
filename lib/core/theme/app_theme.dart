import 'package:flutter/material.dart';
import 'package:firy_streak/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.primaryDark,
      surface: AppColors.background,
      error: AppColors.error,
    ),

    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.textDark),
    ),

    textTheme: GoogleFonts.nunitoSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          fontSize: 32,
        ),

        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          fontSize: 24,
        ),

        bodyLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkGrey,
          fontSize: 18,
        ),

        bodyMedium: TextStyle(
          fontWeight: FontWeight.normal,
          color: AppColors.darkGrey,
          fontSize: 16,
        ),
      ),
    ),

    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.blue),
    
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
    ),
  );
}
