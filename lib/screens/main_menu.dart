import 'package:flutter/material.dart';
import 'game_screen.dart'; // Game screen will be created in Phase 5

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Menu"), // ✅ Matches your widget test
        centerTitle: true,
      ),
      body: Container(
        color: Colors.green[200], // placeholder table color
        child: Center(
          child: SingleChildScrollView( // keeps layout safe on small screens
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  child: const Text("Start Game"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Rules screen coming soon!")),
                    );
                  },
                  child: const Text("Rules"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Settings screen coming soon!")),
                    );
                  },
                  child: const Text("Settings"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}