import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:async';

import 'sync_service_interface.dart';

class BluetoothSyncService implements SyncService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;

  void Function(String message)? _onMessageCallback;
  void Function()? _onConnected;
  void Function()? _onDisconnected;
  void Function()? _onLagDetected;
  void Function()? _onResync;

  Timer? _heartbeatTimer;
  DateTime? _lastPingTime;

  final bool testMode;

  BluetoothSyncService({this.testMode = false});

  @override
  Future<List<BluetoothDevice>> getPairedDevices() async {
    if (testMode) return [];
    try {
      final isEnabled = await _bluetooth.isEnabled;
      if (isEnabled != true) {
        await _bluetooth.requestEnable();
      }
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      debugPrint("⚠️ Error while scanning: $e");
      return [];
    }
  }

  @override
  Future<void> connectToDevice(String address) async {
    if (testMode) {
      debugPrint("🧪 Test mode: skipping Bluetooth connection");
      _onConnected?.call();
      return;
    }

    try {
      _connection = await BluetoothConnection.toAddress(address);
      debugPrint('✅ Connected to device: $address');
      _onConnected?.call();
      startHeartbeat();

      _connection!.input?.listen((data) {
        final message = utf8.decode(data);
        debugPrint('📥 Incoming: $message');
        _onMessageCallback?.call(message);

        if (message == 'pong') {
          final now = DateTime.now();
          final latency = now.difference(_lastPingTime ?? now).inMilliseconds;
          debugPrint('⏱️ Ping latency: ${latency}ms');
          if (latency > 3000) {
            _onLagDetected?.call();
          }
        }
      }).onDone(() {
        debugPrint('❌ Disconnected by remote device');
        _connection = null;
        _heartbeatTimer?.cancel();
        _onDisconnected?.call();
      });
    } catch (e) {
      debugPrint("⚠️ Connection error: $e");
    }
  }

  @override
  void sendMessage(String message) {
    if (_connection?.isConnected == true && _connection?.output != null) {
      final bytes = Uint8List.fromList(utf8.encode(message));
      _connection!.output.add(bytes);
      debugPrint("📤 Sent message: $message");
    } else {
      debugPrint("⚠️ No active connection to send message.");
    }
  }

  @override
  void sendGameState(Map<String, dynamic> state) {
    sendMessage(jsonEncode(state));
  }

  @override
  void sendPing() {
    _lastPingTime = DateTime.now();
    sendMessage('ping');
  }

  @override
  void startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      sendPing();
    });
  }

  @override
  void triggerResync() {
    _onResync?.call();
  }

  @override
  void onMessageReceived(void Function(String message) callback) {
    _onMessageCallback = callback;
  }

  @override
  void onConnected(void Function() callback) {
    _onConnected = callback;
  }

  @override
  void onDisconnected(void Function() callback) {
    _onDisconnected = callback;
  }

  @override
  void onLagDetected(void Function() callback) {
    _onLagDetected = callback;
  }

  @override
  void onResync(void Function() callback) {
    _onResync = callback;
  }

  @override
  void disconnect() {
    _heartbeatTimer?.cancel();
    if (_connection != null) {
      _connection!.dispose();
      _connection = null;
      debugPrint("🔌 Disconnected from device.");
      _onDisconnected?.call();
    }
  }

  @override
  bool get isConnected => _connection?.isConnected == true;

  /// ✅ Test-only: inject mock connection
  @visibleForTesting
  set testConnection(BluetoothConnection connection) => _connection = connection;

  /// ✅ Test-only: trigger incoming message manually
  @visibleForTesting
  void triggerMessage(String message) => _onMessageCallback?.call(message);
}