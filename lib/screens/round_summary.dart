import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/presence_service.dart';
import '../services/room_service.dart';
import '../localization/strings.dart';
import 'main_menu.dart';

class RoundSummary extends StatelessWidget {
  final int team1Score;
  final int team2Score;
  final int roundNumber;
  final FirebaseService firebaseService;
  final Strings strings;
  final AuthService? authService;
  final PresenceService? presenceService;
  final RoomService? roomService;

  const RoundSummary({
    super.key,
    required this.team1Score,
    required this.team2Score,
    required this.roundNumber,
    required this.firebaseService,
    required this.strings,
    this.authService,
    this.presenceService,
    this.roomService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(strings.viewRules)),
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: const Text("Team 2"),
                trailing: Text(
                  "$team2Score",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              key: const Key('mainMenuButton'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainMenu(
                      firebaseService: firebaseService,
                      strings: strings,
                      authService: authService,
                      presenceService: presenceService,
                      roomService: roomService,
                    ),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: Text(strings.mainMenuTitle),
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