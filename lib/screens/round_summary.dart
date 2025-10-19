import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'main_menu.dart'; // so we can navigate back

class RoundSummary extends StatelessWidget {
  final int team1Score;
  final int team2Score;
  final int roundNumber;
  final FirebaseService firebaseService; // ✅ add this

  const RoundSummary({
    super.key,
    this.team1Score = 0,
    this.team2Score = 0,
    this.roundNumber = 1,
    required this.firebaseService, // ✅ required
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Round Summary")),
      body: Container(
        color: Colors.purple[50],
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "📊 Round $roundNumber Results",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text("Team 1"),
                trailing: Text(
                  "$team1Score",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text("Team 2"),
                trailing: Text(
                  "$team2Score",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MainMenu(firebaseService: firebaseService), // ✅ pass service
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: const Text("Back to Main Menu"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}