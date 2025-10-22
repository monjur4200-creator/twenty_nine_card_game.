import 'package:test/test.dart';
import 'package:twenty_nine_card_game/models/room_models.dart';

void main() {
  group('RoomModel', () {
    late RoomModel room;

    setUp(() {
      room = RoomModel(
        roomId: 'r1',
        hostId: 'host123',
        players: ['p1', 'p2'],
        isPrivate: true,
        status: RoomStatus.active,
      );
    });

    test('toMap serializes correctly', () {
      final map = room.toMap();
      expect(map['roomId'], equals('r1'));
      expect(map['hostId'], equals('host123'));
      expect(map['players'], unorderedEquals(['p1', 'p2']));
      expect(map['isPrivate'], isTrue);
      expect(map['status'], equals('active'));
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'roomId': 'r1',
        'hostId': 'host123',
        'players': ['p1', 'p2'],
        'isPrivate': true,
        'status': 'active',
      };
      final fromMap = RoomModel.fromMap(map);
      expect(fromMap, equals(room));
    });

    test('fromMap uses defaults for missing fields', () {
      final map = <String, dynamic>{
        'roomId': 'fallback',
        'hostId': 'fallback_host',
      };
      final model = RoomModel.fromMap(Map<String, dynamic>.from(map));

      expect(model.roomId, equals('fallback'));
      expect(model.hostId, equals('fallback_host'));
      expect(model.players, isEmpty);
      expect(model.isPrivate, isFalse);
      expect(model.status, equals(RoomStatus.waiting));
    });

    test('fromMap falls back to waiting for invalid status', () {
      final map = {
        'roomId': 'rX',
        'hostId': 'hX',
        'status': 'not_a_real_status',
      };
      final model = RoomModel.fromMap(map);
      expect(model.status, equals(RoomStatus.waiting));
    });

    test('copyWith creates updated instance immutably', () {
      final updated = room.copyWith(
        roomId: 'r2',
        players: ['p3'],
        status: RoomStatus.finished,
      );

      expect(updated.roomId, equals('r2'));
      expect(updated.players, unorderedEquals(['p3']));
      expect(updated.status, equals(RoomStatus.finished));
      expect(room.roomId, equals('r1')); // original unchanged
    });

    test('copyWith with no changes returns equal object', () {
      final clone = room.copyWith();
      expect(clone, equals(room));
    });

    test('isHost returns true for host ID', () {
      expect(room.isHost('host123'), isTrue);
      expect(room.isHost('p1'), isFalse);
    });

    test('equality matches identical rooms', () {
      final clone = RoomModel(
        roomId: 'r1',
        hostId: 'host123',
        players: ['p1', 'p2'],
        isPrivate: true,
        status: RoomStatus.active,
      );

      expect(clone, equals(room));
      expect(clone.hashCode, isA<int>());
    });

    test('toString returns readable format', () {
      final str = room.toString();
      expect(str, contains('roomId: r1'));
      expect(str, contains('hostId: host123'));
      expect(str, contains('players: [p1, p2]'));
      expect(str, contains('isPrivate: true'));
      expect(str, contains('status: RoomStatus.active'));
    });
  });
}
