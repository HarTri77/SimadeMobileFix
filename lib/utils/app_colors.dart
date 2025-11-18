// lib/utils/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // 🌈 Primary Colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color teal = Color(0xFF48C9B0);
  static const Color purple = Color(0xFF9B59B6);
  static const Color pastelGreen = Color(0xFF98D8C8);
  static const Color darkNavy = Color(0xFF1A1A2E);
  static const backgroundLight = Color(0xFFF6F7FB);


  // 🌙 Neutral / Background Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFFBDBDBD);
  static const Color lightGrey = Color(0xFFF5F5F5);

  // 🚦 Status Colors
  static const Color successColor = Color(0xFF2ECC71);
  static const Color warningColor = Color(0xFFF1C40F);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color infoColor = Color(0xFF3498DB);

  // 🎨 Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [purple, Color(0xFF667EEA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundGradient = LinearGradient(
    colors: [
      skyBlue.withOpacity(0.1),
      teal.withOpacity(0.05),
      Colors.white,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🧭 Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];

  // 🧱 Border Colors
  static const Color borderColor = Color(0xFFE0E0E0);
}
