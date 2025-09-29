import 'package:flutter/material.dart';

class ReservationDesignSystem {
  // Color Palette
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFBFF);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  // Typography
  static TextStyle displayLarge(bool isMobile) => TextStyle(
    fontSize: isMobile ? 24 : 28,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static TextStyle titleLarge(bool isMobile) => TextStyle(
    fontSize: isMobile ? 18 : 20,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle bodyLarge(bool isMobile) => TextStyle(
    fontSize: isMobile ? 16 : 18,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle bodySmall(bool isMobile) => TextStyle(
    fontSize: isMobile ? 12 : 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  // Spacing
  static double getSectionPadding(bool isMobile) => isMobile ? 16 : 24;
  static double getCardPadding(bool isMobile) => isMobile ? 16 : 20;
  static double getElementSpacing(bool isMobile) => isMobile ? 12 : 16;

  // Decorations
  static BoxDecoration cardDecoration(bool isMobile) => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: Offset(0, 4),
      ),
    ],
    border: Border.all(color: Colors.grey[100]!),
  );

  static BoxDecoration gradientHeader(bool isMobile) => BoxDecoration(
    gradient: LinearGradient(
      colors: [primaryMaroon, lightMaroon],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
    boxShadow: [
      BoxShadow(
        color: primaryMaroon.withOpacity(0.3),
        blurRadius: 15,
        offset: Offset(0, 6),
      ),
    ],
  );
}