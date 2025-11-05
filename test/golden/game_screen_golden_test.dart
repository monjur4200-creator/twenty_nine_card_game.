import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/screens/game_screen.dart';
import 'package:twenty_nine_card_game/localization/strings.dart';
import 'package:twenty_nine_card_game/models/player.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';
import 'package:twenty_nine_card_game/services/sync_service_interface.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DummySyncService implements SyncService {
  @override
  Future<void> connectToDevice(String address) async {}

  @override
  void disconnect() {}

  @override
  void sendMessage(String message) {}

  @override
  void sendGameState(Map<String, dynamic> state) {}

  @override
  void sendPing() {}

  @override
  void startHeartbeat() {}

  @override
  void triggerResync() {}

  @override
  void onMessageReceived(void Function(String message) callback) {}

  @override
  void onConnected(void Function() callback) {}

  @override
  void onDisconnected(void Function() callback) {}

  @override
  void onLagDetected(void Function() callback) {}

  @override
  void onResync(void Function() callback) {}

  @override
  bool get isConnected => true;

  @override
  Future<List<BluetoothDevice>> getPairedDevices() async => <BluetoothDevice>[];
}

void main() {
  testWidgets('GameScreen golden test', (tester) async {
    final testPlayer = Player(
      id: 1,
      name: 'TestPlayer',
      teamId: 1,
      loginMethod: LoginMethod.guest,
      connectionType: ConnectionType.local,
    );

    final firebase = FirebaseService(
      auth: MockFirebaseAuth(),
      firestore: FakeFirebaseFirestore(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: RepaintBoundary(
            child: GameScreen(
              firebaseService: firebase,
              strings: Strings('en'),
              player: testPlayer,
              syncService: DummySyncService(),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(GameScreen),
      matchesGoldenFile('goldens/game_screen.png'),
    );
  });
}