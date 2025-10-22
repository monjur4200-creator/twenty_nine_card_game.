import 'package:test/test.dart';
import 'package:twenty_nine_card_game/models/room_models.dart';

void main() {
  group('LobbyModel', () {
    late RoomModel room1;
    late RoomModel room2;
    late RoomModel room3;

    setUp(() {
      room1 = RoomModel(
        roomId: 'r1',
        hostId: 'h1',
        players: ['p1', 'p2'],
        isPrivate: false,
        status: RoomStatus.waiting,
      );

      room2 = RoomModel(
        roomId: 'r2',
        hostId: 'h2',
        players: ['p3', 'p4'],
        isPrivate: true,
        status: RoomStatus.active,
      );

      room3 = RoomModel(
        roomId: 'r3',
        hostId: 'h3',
        players: ['p5'],
        isPrivate: false,
        status: RoomStatus.finished,
      );
    });

    test('addRoom adds a room immutably', () {
      final lobby = LobbyModel().addRoom(room1);
      expect(lobby.rooms, hasLength(1));
      expect(lobby.rooms.first, equals(room1));
    });

    test('removeRoom removes a room by ID', () {
      final lobby = LobbyModel(rooms: [room1, room2]).removeRoom('r1');
      expect(lobby.rooms, hasLength(1));
      expect(lobby.rooms.first, equals(room2));
    });

    test('removeRoom with non-existent ID leaves unchanged', () {
      final lobby = LobbyModel(
        rooms: [room1, room2],
      ).removeRoom('doesNotExist');
      expect(lobby.rooms, unorderedEquals([room1, room2]));
    });

    test('findRoom returns correct room or null', () {
      final lobby = LobbyModel(rooms: [room1, room2]);
      expect(lobby.findRoom('r2'), equals(room2));
      expect(lobby.findRoom('doesNotExist'), isNull);
    });

    test('hasRoom returns true if room exists', () {
      final lobby = LobbyModel(rooms: [room1, room2]);
      expect(lobby.hasRoom('r1'), isTrue);
      expect(lobby.hasRoom('r9'), isFalse);
    });

    test('publicRooms and privateRooms filters work', () {
      final lobby = LobbyModel(rooms: [room1, room2, room3]);
      expect(lobby.publicRooms, containsAll([room1, room3]));
      expect(lobby.privateRooms, unorderedEquals([room2]));
    });

    test('status filters work', () {
      final lobby = LobbyModel(rooms: [room1, room2, room3]);
      expect(lobby.waitingRooms, unorderedEquals([room1]));
      expect(lobby.activeRooms, unorderedEquals([room2]));
      expect(lobby.finishedRooms, unorderedEquals([room3]));
    });

    test('roomCountByStatus returns correct counts', () {
      final lobby = LobbyModel(rooms: [room1, room2, room3]);
      expect(lobby.roomCountByStatus(RoomStatus.waiting), equals(1));
      expect(lobby.roomCountByStatus(RoomStatus.active), equals(1));
      expect(lobby.roomCountByStatus(RoomStatus.finished), equals(1));
    });

    test('serialization round-trip preserves equality', () {
      final lobby = LobbyModel(rooms: [room1, room2, room3]);
      final map = lobby.toMap();
      final fromMap = LobbyModel.fromMap(map);

      expect(fromMap, equals(lobby));
      expect(fromMap.toMap(), equals(map));
    });

    test('copyWith creates updated instance immutably', () {
      final lobby = LobbyModel(rooms: [room1]);
      final updated = lobby.copyWith(rooms: [room1, room2]);

      expect(updated.rooms, hasLength(2));
      expect(lobby.rooms, hasLength(1)); // original unchanged
    });
  });
}
