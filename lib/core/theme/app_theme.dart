import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _accentColor = Color(0xFFFF003A); // Electric Red
  static const _bgColor = Color(0xFF000000); // Pitch Black
  static const _surfaceColor = Color(0xFF121212); // Deep Grey

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _accentColor,
      brightness: Brightness.light,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bgColor,
      colorScheme: const ColorScheme.dark(
        primary: _accentColor,
        onPrimary: Colors.white,
        secondary: _accentColor,
        surface: _surfaceColor,
        onSurface: Colors.white,
        background: _bgColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
