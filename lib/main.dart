 import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';

class MyOwnResolver implements SongUrlResolver {
  @override
  Future<String> resolve(String songId) async {
    // https://ghproxy.net/raw.githubusercontent.com/pdone/lx-music-source/main/sixyin/latest.js
    https://ghproxy.net/raw.githubusercontent.com/pdone/lx-music-source/main/huibq/latest.js
    return 'https://你的服务器地址/song/$songId.mp3';
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PlayerScreen.resolver = MyOwnResolver();
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
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
