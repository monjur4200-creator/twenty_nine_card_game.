import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:twenty_nine_card_game/widgets/player_banner.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart'; // Make sure this import exists

void main() {
  testWidgets('PlayerBanner shows name and connection icon', (tester) async {
    final player = Player(
      id: 1,
      name: 'Mongur',
      teamId: 1,
      loginMethod: LoginMethod.guest,
      connectionType: ConnectionType.local, // ✅ Added required parameter
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PlayerBanner(player: player, isConnected: true),
      ),
    );

    expect(find.text('Mongur'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}