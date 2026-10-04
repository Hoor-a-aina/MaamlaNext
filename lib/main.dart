import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/chat_screen.dart';

void main() {
  runApp(const MaamlaNextApp());
}

class MaamlaNextApp extends StatefulWidget {
  const MaamlaNextApp({super.key}); // Cleaned up deprecated Key? key syntax

  @override
  State<MaamlaNextApp> createState() => _MaamlaNextAppState();
}

class _MaamlaNextAppState extends State<MaamlaNextApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _updateTheme(ThemeMode newMode) {
    setState(() {
      _themeMode = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaamlaNext',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: ChatScreen(
        onThemeChanged: _updateTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }
}