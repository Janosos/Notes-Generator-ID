import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF0d9488); // Teal-600
  static const Color secondary = Color(0xFF0f172a); // Slate-900
  
  static const Color backgroundLight = Color(0xFFf8fafc); // Slate-50
  static const Color backgroundDark = Color(0xFF0f172a); // Slate-900
  
  static const Color surfaceLight = Color(0xFFffffff);
  static const Color surfaceDark = Color(0xFF1e293b); // Slate-800

  static const Color textLight = Color(0xFF1e293b); // Slate-800
  static const Color textDark = Color(0xFFf8fafc); // Slate-50

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surfaceLight,
        //* background: backgroundLight, // 'background' is deprecated in newer Flutter, but usually surface/scaffoldBackgroundColor handles it.
        onPrimary: Colors.white,
        onSurface: textLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textLight,
        displayColor: textLight,
      ),
      iconTheme: const IconThemeData(color: secondary),
      /* cardTheme: CardTheme(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFe2e8f0)), // Slate-200
        ),
      ), */
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: Colors.white,
        surface: surfaceDark,
        //* background: backgroundDark,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
       /* cardTheme: CardTheme(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155)), // Slate-700
        ),
      ), */
    );
  }
}
