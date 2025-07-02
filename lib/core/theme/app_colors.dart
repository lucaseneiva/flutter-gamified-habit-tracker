// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Cores da Marca (Brand)
  static const Color primary = Color(0xFFFE7605); // O nosso laranja principal
  static const Color primaryDark = Color(0xFFE5570B); // Um tom mais escuro para hover/pressed
  
  static const Color blue = Color(0xFF39A3FF);
  // Cores Neutras
  static const Color background = Color(0xFFF9FAFB); // Cinza claro de fundo
  static const Color white = Colors.white;
  static const Color lightGrey = Color(0xFFE0E0E0); // Bordas e divisores
  static const Color darkGrey = Color(0xFF4F4F4F); // Texto secundário
  static const Color textDark = Color(0xFF333333); // Texto principal

  // Cores de Feedback
  static const Color success = Colors.green;
  static const Color error = Colors.red;
}
