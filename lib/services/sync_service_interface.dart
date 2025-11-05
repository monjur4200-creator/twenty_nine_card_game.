import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// Abstract interface for syncing game state across devices.
/// Can be implemented via Bluetooth, WebSocket, or mock services.
abstract class SyncService {
  /// Returns a list of paired Bluetooth devices.
  Future<List<BluetoothDevice>> getPairedDevices();

  /// Connects to a device using its Bluetooth address.
  Future<void> connectToDevice(String address);

  /// Disconnects from the current connection.
  void disconnect();

  /// Sends a raw string message to the connected device.
  void sendMessage(String message);

  /// Sends a game state map as a JSON string.
  void sendGameState(Map<String, dynamic> state);

  /// Sends a ping message to measure latency.
  void sendPing();

  /// Starts periodic heartbeat pings to monitor connection health.
  void startHeartbeat();

  /// Triggers a manual resync event.
  void triggerResync();

  /// Registers a callback for incoming messages.
  void onMessageReceived(void Function(String message) callback);

  /// Registers a callback for successful connection.
  void onConnected(void Function() callback);

  /// Registers a callback for disconnection.
  void onDisconnected(void Function() callback);

  /// Registers a callback for lag detection (e.g. high latency).
  void onLagDetected(void Function() callback);

  /// Registers a callback for resync triggers.
  void onResync(void Function() callback);

  /// Returns true if currently connected to a device.
  bool get isConnected;
}