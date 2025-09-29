import 'package:flutter/material.dart';

class AppColors {
  // Maroon theme colors
  static const Color primary = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFA52A2A);
  static const Color accent = Color(0xFF722F37);
  
  // Background colors
  static const Color background = Color(0xFFFAF7F7);
  
  // Role-based gradient colors
  static const Map<String, List<Color>> roleGradients = {
    'user': [Color(0xFF48BB78), Color(0xFF38A169)], // Green
    'admin': [Color(0xFF4299E1), Color(0xFF3182CE)], // Blue
    'super_admin': [Color(0xFFE53E3E), Color(0xFFC53030)], // Red
    'default': [Color(0xFFA0AEC0), Color(0xFF718096)], // Gray
  };
  
  // Status colors
  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFED8936);
  static const Color info = Color(0xFF4299E1);
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: _createMaterialColor(AppColors.primary),
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.darkMaroon,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    ),
  );
  
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }
}