import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/models/game_event.dart';

void main() {
  group('GameEvent', () {
    test('toJson serializes correctly', () {
      final event = GameEvent(
        type: 'playCard',
        payload: {
          'playerId': 'p1',
          'card': {'suit': 'hearts', 'rank': 'K'},
        },
      );

      final json = event.toJson();
      expect(json, contains('"type":"playCard"'));
      expect(json, contains('"playerId":"p1"'));
      expect(json, contains('"suit":"hearts"'));
      expect(json, contains('"rank":"K"'));
    });

    test('fromJson deserializes correctly', () {
      const json = '''
        {
          "type": "bid",
          "payload": {
            "playerId": "p2",
            "amount": 16
          }
        }
      ''';

      final event = GameEvent.fromJson(json);
      expect(event.type, 'bid');
      expect(event.payload['playerId'], 'p2');
      expect(event.payload['amount'], 16);
    });

    test('round-trip serialization works', () {
      final original = GameEvent(
        type: 'scoreUpdate',
        payload: {'teamA': 28, 'teamB': 16},
      );

      final json = original.toJson();
      final parsed = GameEvent.fromJson(json);

      expect(parsed.type, original.type);
      expect(parsed.payload, original.payload);
    });
  });
}
