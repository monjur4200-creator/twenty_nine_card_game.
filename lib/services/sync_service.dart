import 'package:flutter/foundation.dart'; // for debugPrint and Uint8List
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SyncService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;

  /// Get list of paired (bonded) devices
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      bool? isEnabled = await _bluetooth.isEnabled;
      if (isEnabled != true) {
        await _bluetooth.requestEnable();
      }

      final devices = await _bluetooth.getBondedDevices();
      return devices;
    } catch (e) {
      debugPrint("⚠️ Error while scanning: $e");
      return [];
    }
  }

  /// Connect to a device by its Bluetooth address
  Future<void> connectToDevice(String address) async {
    try {
      _connection = await BluetoothConnection.toAddress(address);
      debugPrint('✅ Connected to device: $address');

      _connection!.input?.listen((data) {
        debugPrint('📥 Incoming: ${String.fromCharCodes(data)}');
      }).onDone(() {
        debugPrint('❌ Disconnected by remote device');
        _connection = null;
      });
    } catch (e) {
      debugPrint("⚠️ Connection error: $e");
    }
  }

  /// Send game state as a string (for now)
  void sendGameState(Map<String, dynamic> state) {
    if (_connection != null && _connection!.isConnected) {
      final message = state.toString();
      _connection!.output.add(Uint8List.fromList(message.codeUnits));
      debugPrint("📤 Sent game state: $message");
    } else {
      debugPrint("⚠️ No active connection to send game state.");
    }
  }

  /// Disconnect gracefully
  void disconnect() {
    if (_connection != null) {
      _connection!.dispose();
      _connection = null;
      debugPrint("🔌 Disconnected from device.");
    }
  }
}