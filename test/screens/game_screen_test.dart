import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:twenty_nine_card_game/screens/game_screen.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';

import 'package:twenty_nine_card_game/services/sync_service.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';
import 'package:twenty_nine_card_game/localization/strings.dart';

class DummyFirebaseService implements FirebaseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late BluetoothSyncService syncService;

  setUp(() {
    syncService = BluetoothSyncService();
  });

  tearDown(() {
    syncService.disconnect(); // ✅ Stops heartbeat timer
  });

  testWidgets('GameScreen renders and runs simulation', (tester) async {
    final player = Player(
      id: 1,
      name: 'Mongur',
      teamId: 1,
      loginMethod: LoginMethod.guest,
      connectionType: ConnectionType.bluetooth,
    );

    await tester.pumpWidget(MaterialApp(
      home: GameScreen(
        firebaseService: DummyFirebaseService(),
        strings: Strings('en'),
        player: player,
        syncService: syncService,
      ),
    ));

    expect(find.byKey(const Key('gameScreenTitle')), findsOneWidget);

    await tester.tap(find.byKey(const Key('playButton')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Round'), findsWidgets);
  });
}