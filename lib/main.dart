import 'package:flutter/material.dart';
import 'screens/main_menu.dart'; // Main Menu screen

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
        colorSchemeSeed: Colors.teal, // Material 3-friendly color setup
        useMaterial3: true,
      ),
      home: const MainMenu(), // Start at Main Menu
    );
  }
}