import 'dart:convert';

class GameEvent {
  final String type; // e.g. 'playCard', 'bid', 'scoreUpdate'
  final Map<String, dynamic> payload;

  GameEvent({
    required this.type,
    required this.payload,
  });

  /// Convert to JSON string for transmission
  String toJson() => jsonEncode({
        'type': type,
        'payload': payload,
      });

  /// Parse from JSON string
  static GameEvent fromJson(String json) {
    final map = jsonDecode(json);
    return GameEvent(
      type: map['type'],
      payload: Map<String, dynamic>.from(map['payload']),
    );
  }
}
