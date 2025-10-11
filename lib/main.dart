import 'package:flutter/material.dart';

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
      home: const Scaffold(
        body: Center(
          child: Text(
            'Welcome to 29!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
