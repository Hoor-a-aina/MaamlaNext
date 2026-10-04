import 'package:flutter/material.dart';

class AppTheme {
  // Professional Cyber/GovTech Teal & Mint Palette
  static const Color tealPrimary = Color(0xFF0891B2);
  static const Color tealLight = Color(0xFF0EA5E9);
  static const Color mintAccent = Color(0xFF2DD4BF);
  static const Color obsidianDark = Color(0xFF070B14);

  // High-End Professional Gradients
  static const LinearGradient tealMintGradient = LinearGradient(
    colors: [tealLight, mintAccent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: tealPrimary,
        secondary: mintAccent,
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF0F172A),
        surfaceContainerHighest: const Color(0xFFF1F5F9),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: mintAccent,
        secondary: tealLight,
        surface: const Color(0xFF0F172A),
        onSurface: const Color(0xFFF8FAFC),
        surfaceContainerHighest: const Color(0xFF1E293B),
      ),
      scaffoldBackgroundColor: obsidianDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}