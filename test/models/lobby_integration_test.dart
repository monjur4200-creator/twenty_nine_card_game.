import 'package:test/test.dart';
import 'package:twenty_nine_card_game/models/room_models.dart';

void main() {
  group('LobbyModel integration', () {
    final room1 = RoomModel(
      roomId: 'r1',
      hostId: 'h1',
      players: ['p1', 'p2'],
      isPrivate: false,
      status: RoomStatus.waiting,
    );

    final room2 = RoomModel(
      roomId: 'r2',
      hostId: 'h2',
      players: ['p3'],
      isPrivate: true,
      status: RoomStatus.active,
    );

    final room3 = RoomModel(
      roomId: 'r3',
      hostId: 'h3',
      players: ['p4', 'p5'],
      isPrivate: false,
      status: RoomStatus.finished,
    );

    test('full pipeline: add, serialize, deserialize, compare', () {
      // Step 1: Create lobby and add rooms
      final lobby = LobbyModel().addRoom(room1).addRoom(room2).addRoom(room3);

      expect(lobby.rooms, hasLength(3));

      // Step 2: Serialize to map
      final map = lobby.toMap();
      expect(map['rooms'], isA<List<dynamic>>());
      expect((map['rooms'] as List).length, equals(3));

      // Step 3: Deserialize back
      final fromMap = LobbyModel.fromMap(map);

      // Step 4: Assert equality
      expect(fromMap, equals(lobby));

      // Step 5: Check filters still work (matcher-clean)
      expect(fromMap.publicRooms, unorderedEquals([room1, room3]));
      expect(fromMap.privateRooms, unorderedEquals([room2]));
      expect(fromMap.waitingRooms, unorderedEquals([room1]));
      expect(fromMap.activeRooms, unorderedEquals([room2]));
      expect(fromMap.finishedRooms, unorderedEquals([room3]));
    });
  });
}
