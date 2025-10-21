import 'package:flutter/material.dart';

class AppDesignSystem {

  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color maroonAccent = Color(0xFF6D1B2B);
  
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFBFF);
  static const Color backgroundColor = warmGray;
  
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color neutralGray = Color(0xFF6B7280);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  
  // Accent Colors
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color softMaroon = Color(0xFFF3E5F5);

  // ============================================
  // TYPOGRAPHY
  // ============================================
  
  static TextStyle displayLarge(bool isMobile) => TextStyle(
    fontSize: isMobile ? 24 : 32,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
    height: 1.2,
    color: textPrimary,
  );
  
  static TextStyle displayMedium(bool isMobile) => TextStyle(
    fontSize: isMobile ? 20 : 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.25,
    height: 1.2,
    color: textPrimary,
  );
  
  static TextStyle titleLarge(bool isMobile) => TextStyle(
    fontSize: isMobile ? 18 : 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.3,
    color: textPrimary,
  );
  
  static TextStyle titleMedium(bool isMobile) => TextStyle(
    fontSize: isMobile ? 16 : 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.3,
    color: textPrimary,
  );
  
  static TextStyle titleSmall(bool isMobile) => TextStyle(
    fontSize: isMobile ? 14 : 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: textPrimary,
  );
  
  static TextStyle bodyLarge(bool isMobile) => TextStyle(
    fontSize: isMobile ? 16 : 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
    color: textSecondary,
  );
  
  static TextStyle bodyMedium(bool isMobile) => TextStyle(
    fontSize: isMobile ? 14 : 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05,
    height: 1.5,
    color: textSecondary,
  );
  
  static TextStyle bodySmall(bool isMobile) => TextStyle(
    fontSize: isMobile ? 12 : 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.05,
    height: 1.5,
    color: textSecondary,
  );
  
  static TextStyle labelLarge(bool isMobile) => TextStyle(
    fontSize: isMobile ? 14 : 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static TextStyle labelMedium(bool isMobile) => TextStyle(
    fontSize: isMobile ? 12 : 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  static TextStyle labelSmall(bool isMobile) => TextStyle(
    fontSize: isMobile ? 10 : 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ============================================
  // SPACING
  // ============================================
  
  static double getSectionPadding(bool isMobile) => isMobile ? 16.0 : 24.0;
  static double getElementSpacing(bool isMobile) => isMobile ? 12.0 : 16.0;
  static double getCardPadding(bool isMobile) => isMobile ? 16.0 : 20.0;
  static double getSmallSpacing(bool isMobile) => isMobile ? 8.0 : 12.0;
  static double getLargeSpacing(bool isMobile) => isMobile ? 24.0 : 32.0;

  // ============================================
  // BORDER RADIUS
  // ============================================
  
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 20.0;
  static const double dialogRadius = 24.0;

  // ============================================
  // SHADOWS & ELEVATION
  // ============================================
  
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primaryMaroon.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryMaroon.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  // ============================================
  // DECORATIONS
  // ============================================
  
  static BoxDecoration cardDecoration({bool hasBorder = true}) => BoxDecoration(
    gradient: LinearGradient(
      colors: [cardBackground, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(cardRadius),
    border: hasBorder ? Border.all(color: Colors.grey[100]!, width: 1) : null,
    boxShadow: cardShadow,
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
        offset: const Offset(0, 6),
      ),
    ],
  );
  
  static BoxDecoration timelineItemDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey[200]!, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration commentBoxDecoration() => BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.blue.shade200, width: 1),
  );
  
  static BoxDecoration statusBadgeDecoration(Color color) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(chipRadius),
    border: Border.all(color: color.withOpacity(0.3), width: 1),
  );
  
  static BoxDecoration stepBadgeDecoration(int stepOrder) => BoxDecoration(
    color: getStepColor(stepOrder).withOpacity(0.1),
    borderRadius: BorderRadius.circular(chipRadius),
    border: Border.all(color: getStepColor(stepOrder).withOpacity(0.3), width: 1),
  );

  // ============================================
  // BUTTON STYLES
  // ============================================
  
  static ButtonStyle primaryButtonStyle(bool isMobile) => ElevatedButton.styleFrom(
    backgroundColor: primaryMaroon,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 20 : 24,
      vertical: isMobile ? 12 : 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
  );
  
  static ButtonStyle secondaryButtonStyle(bool isMobile) => OutlinedButton.styleFrom(
    foregroundColor: primaryMaroon,
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 20 : 24,
      vertical: isMobile ? 12 : 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
    side: const BorderSide(color: primaryMaroon, width: 1.5),
  );
  
  static ButtonStyle textButtonStyle(bool isMobile) => TextButton.styleFrom(
    foregroundColor: primaryMaroon,
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 16 : 20,
      vertical: isMobile ? 8 : 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
  );

  static ButtonStyle dangerButtonStyle(bool isMobile) => ElevatedButton.styleFrom(
    backgroundColor: errorRed,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 20 : 24,
      vertical: isMobile ? 12 : 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
    elevation: 0,
  );

  // ============================================
  // INPUT DECORATION
  // ============================================
  
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primaryMaroon) : null,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
      borderSide: const BorderSide(color: primaryMaroon, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
      borderSide: const BorderSide(color: errorRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
      borderSide: const BorderSide(color: errorRed, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return successGreen;
      case 'rejected':
        return errorRed;
      case 'pending':
        return warningOrange;
      case 'cancelled':
        return neutralGray;
      default:
        return neutralGray;
    }
  }
  
  /// Get icon for status
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }
  
  /// Get color for step based on order
  static Color getStepColor(int stepOrder) {
    switch (stepOrder % 5) {
      case 1:
        return primaryMaroon;
      case 2:
        return infoBlue;
      case 3:
        return successGreen;
      case 4:
        return warningOrange;
      case 0:
        return neutralGray;
      default:
        return neutralGray;
    }
  }

  /// Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 691.2;
  }
}