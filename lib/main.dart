import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

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
      theme: ThemeData(primarySwatch: Colors.teal),
      home: MyGameScreen(), // ✅ No const
    );
  }
}