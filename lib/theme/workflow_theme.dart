// themes/workflow_theme.dart
import 'package:flutter/material.dart';

class WorkflowTheme {
  // Color Palette
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color maroonAccent = Color(0xFF6D1B2B);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFBFF);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color errorRed = Color(0xFFC62828);

  // Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: darkMaroon,
    letterSpacing: 0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: darkMaroon,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );

  // Gradients
  static Gradient get primaryGradient => LinearGradient(
    colors: [primaryMaroon, lightMaroon, maroonAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient get cardGradient => LinearGradient(
    colors: [cardBackground, Colors.white, Colors.white.withOpacity(0.98)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient get successGradient => LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primaryMaroon.withOpacity(0.15),
      blurRadius: 25,
      offset: Offset(0, 8),
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 15,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get intenseShadow => [
    BoxShadow(
      color: primaryMaroon.withOpacity(0.3),
      blurRadius: 40,
      offset: Offset(0, 20),
      spreadRadius: 5,
    ),
  ];

  // Border Radius
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(24));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(16));
  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(12));
}