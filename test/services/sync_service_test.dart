import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart'; // ✅ Needed for WidgetsFlutterBinding
import 'package:twenty_nine_card_game/services/sync_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Fixes method channel error

  group('BluetoothSyncService (test mode)', () {
    test('can register and trigger message callback', () {
      final syncService = BluetoothSyncService(testMode: true);
      String? received;

      syncService.onMessageReceived((msg) {
        received = msg;
      });

      syncService.triggerMessage('Hello Bots!');
      expect(received, 'Hello Bots!');
    });

    test('can send game state as JSON string', () {
      final syncService = BluetoothSyncService(testMode: true);
      String? sent;

      syncService.onMessageReceived((msg) {
        sent = msg;
      });

      syncService.sendGameState({'round': 1, 'score': 29});
      syncService.triggerMessage('{"round":1,"score":29}');
      expect(sent, '{"round":1,"score":29}');
    });

    test('connectToDevice in test mode triggers onConnected', () async {
      final syncService = BluetoothSyncService(testMode: true);
      bool connected = false;

      syncService.onConnected(() {
        connected = true;
      });

      await syncService.connectToDevice('00:11:22:33:44:55');
      expect(connected, isTrue);
    });
  });
}