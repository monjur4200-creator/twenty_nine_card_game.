import 'package:flutter/material.dart';
import 'game_screen.dart'; // we'll create this later in Phase 5

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Twenty Nine")),
      body: Container(
        color: Colors.green[200], // placeholder table color
        child: Center(
          child: SingleChildScrollView( // keeps layout safe on small screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameScreen()),
                    );
                  },
                  child: const Text("Start Game"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Placeholder for rules screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Rules screen coming soon!")),
                    );
                  },
                  child: const Text("Rules"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Placeholder for settings screen
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