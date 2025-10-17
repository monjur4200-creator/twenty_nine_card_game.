import 'package:flutter/material.dart';
import 'screens/main_menu.dart'; // ✅ import the Main Menu screen
import 'screens/game_screen.dart'; // keep this for navigation later

void main() {
  runApp(const TwentyNineApp());
}

class TwentyNineApp extends StatelessWidget {
  const TwentyNineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '29 Card Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true, // modern Material Design
      ),
      home: const MainMenu(), // ✅ start at Main Menu instead of Game Screen
    );
  }
}