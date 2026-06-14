import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const YueCApp());
}

class YueCApp extends StatelessWidget {
  const YueCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YueC Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF64B5F6),
        scaffoldBackgroundColor: const Color(0xFF0F1535),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F4E),
          foregroundColor: Color(0xFFE8EEFF),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1F4E),
          selectedItemColor: Color(0xFF64B5F6),
          unselectedItemColor: Color(0xFF7799CC),
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF64B5F6),
          surface: const Color(0xFF0F1535),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
