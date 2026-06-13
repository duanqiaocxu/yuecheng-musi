import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YueCApp());
}

class YueCApp extends StatelessWidget {
  const YueCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YueC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4080FF),
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F1535),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F4E),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1F4E),
          selectedItemColor: Color(0xFF4080FF),
          unselectedItemColor: Color(0xFF5566AA),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
