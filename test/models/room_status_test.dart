import 'package:test/test.dart';
import 'package:twenty_nine_card_game/models/room_models.dart';

void main() {
  group('RoomStatus', () {
    test('enum values match expected names', () {
      expect(RoomStatus.waiting.name, equals('waiting'));
      expect(RoomStatus.active.name, equals('active'));
      expect(RoomStatus.finished.name, equals('finished'));
    });

    test('names list returns all enum names', () {
      expect(
        RoomStatus.names,
        unorderedEquals(['waiting', 'active', 'finished']),
      );
    });

    test('values length is fixed at 3', () {
      expect(RoomStatus.values, hasLength(3));
    });

    test('can parse from string using firstWhere', () {
      final status = RoomStatus.values.firstWhere((s) => s.name == 'active');
      expect(status, equals(RoomStatus.active));
    });

    test('fallback to waiting if unknown string', () {
      const unknown = 'paused';
      final status = RoomStatus.values.firstWhere(
        (s) => s.name == unknown,
        orElse: () => RoomStatus.waiting,
      );
      expect(status, equals(RoomStatus.waiting));
    });
  });
}
