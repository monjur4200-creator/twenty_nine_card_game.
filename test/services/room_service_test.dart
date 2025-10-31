import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:twenty_nine_card_game/services/room_service.dart';
import 'package:twenty_nine_card_game/services/room_service_impl.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RoomService roomService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    // ✅ Use the concrete implementation, not the abstract
    roomService = FirestoreRoomService(firestore: fakeFirestore);
  });

  test('createRoom should create a room with default fields', () async {
    await roomService.createRoom('room1', {'hostId': 'host123'});

    final snapshot = await fakeFirestore.collection('rooms').doc('room1').get();
    final data = snapshot.data();

    expect(data, isNotNull);
    expect(data!['status'], 'waiting');
    expect(data['hostId'], 'host123');
    expect(data['players'], isEmpty);
  });

  test('joinRoom should add a player to the room', () async {
    await roomService.createRoom('room1', {'hostId': 'host123'});

    final player = {'id': 'p1', 'name': 'Mongur'};
    await roomService.joinRoom('room1', player);

    final snapshot = await fakeFirestore.collection('rooms').doc('room1').get();
    final players = List<Map<String, dynamic>>.from(snapshot['players']);

    expect(players.length, 1);
    expect(players.first['name'], 'Mongur');
  });

  test('joinRoom should not duplicate the same player', () async {
    await roomService.createRoom('room1', {'hostId': 'host123'});

    final player = {'id': 'p1', 'name': 'Mongur'};
    await roomService.joinRoom('room1', player);
    await roomService.joinRoom('room1', player); // duplicate attempt

    final snapshot = await fakeFirestore.collection('rooms').doc('room1').get();
    final players = List<Map<String, dynamic>>.from(snapshot['players']);

    expect(players.length, 1); // still only one
  });

  test('leaveRoom should remove a player from the room', () async {
    await roomService.createRoom('room1', {'hostId': 'host123'});
    final player = {'id': 'p1', 'name': 'Mongur'};
    await roomService.joinRoom('room1', player);

    await roomService.leaveRoom('room1', player);

    final snapshot = await fakeFirestore.collection('rooms').doc('room1').get();
    final players = List<Map<String, dynamic>>.from(snapshot['players']);

    expect(players, isEmpty);
  });

  test('getPlayerCount should return correct number of players', () async {
    await roomService.createRoom('room1', {'hostId': 'host123'});
    await roomService.joinRoom('room1', {'id': 'p1', 'name': 'Mongur'});
    await roomService.joinRoom('room1', {'id': 'p2', 'name': 'Rafi'});

    final count = await roomService.getPlayerCount('room1');
    expect(count, 2);
  });

  test('updateRoomStatus should change the status field', () async {
    await roomService.createRoom('room1', {'hostId': 'host123'});
    await roomService.updateRoomStatus('room1', 'active');

    final snapshot = await fakeFirestore.collection('rooms').doc('room1').get();
    expect(snapshot['status'], 'active');
  });

  test('deleteRoom should remove the room document', () async {
    await roomService.createRoom('room1', {'hostId': 'host123'});
    await roomService.deleteRoom('room1');

    final snapshot = await fakeFirestore.collection('rooms').doc('room1').get();
    expect(snapshot.exists, false);
  });
}
