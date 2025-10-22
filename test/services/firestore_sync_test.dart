import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:twenty_nine_card_game/services/firestore_sync.dart';

// Helpers for teamScores conversion
import 'package:twenty_nine_card_game/models/utils/firestore_helpers.dart';

// Bring in GameState and related classes
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';

void main() {
  group('FirestoreSync', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreSync sync;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      sync = FirestoreSync.test(fakeFirestore); // using the test constructor
    });

    group('Game State', () {
      test('updateGameState writes to Firestore', () async {
        final roomId = 'room1';
        final gameState = {'roundNumber': 1};

        await sync.updateGameState(roomId, gameState);

        final snapshot = await fakeFirestore
            .collection('rooms')
            .doc(roomId)
            .get();
        expect(snapshot.exists, true);
        expect(snapshot.data()?['gameState']['roundNumber'], 1);
      });

      test('listenToGameState streams updates', () async {
        final roomId = 'room2';
        await fakeFirestore.collection('rooms').doc(roomId).set({
          'gameState': {'roundNumber': 5},
        });

        final stream = sync.listenToGameState(roomId);
        final first = await stream.first;

        expect(first['roundNumber'], 5);
      });
    });

    group('Actions', () {
      test('playCard writes player card to Firestore', () async {
        final roomId = 'room3';
        final playerId = 'p1';
        final card = 'C9';

        await sync.playCard(roomId, playerId, card);

        final snapshot = await fakeFirestore
            .collection('rooms')
            .doc(roomId)
            .get();
        final data = snapshot.data();

        expect(data?['gameState']['playedCards'][playerId], card);
        expect(data?['lastAction']['type'], 'playCard');
      });

      test('revealTrump updates trump suit in Firestore', () async {
        final roomId = 'room4';
        final trumpSuit = 'Hearts';

        await sync.revealTrump(roomId, trumpSuit);

        final snapshot = await fakeFirestore
            .collection('rooms')
            .doc(roomId)
            .get();
        final data = snapshot.data();

        expect(data?['gameState']['trump'], trumpSuit);
        expect(data?['gameState']['trumpRevealed'], true);
        expect(data?['lastAction']['type'], 'revealTrump');
      });

      test('updateTurn writes current turn index', () async {
        final roomId = 'roomTurn';
        await sync.updateTurn(roomId, 2);

        final snapshot = await fakeFirestore
            .collection('rooms')
            .doc(roomId)
            .get();
        final data = snapshot.data();

        expect(data?['gameState']['currentTurn'], 2);
        expect(data?['lastAction']['type'], 'updateTurn');
      });

      test('clearPlayedCards resets playedCards', () async {
        final roomId = 'roomClear';
        await sync.clearPlayedCards(roomId);

        final snapshot = await fakeFirestore
            .collection('rooms')
            .doc(roomId)
            .get();
        final data = snapshot.data();

        expect(data?['gameState']['playedCards'], {});
        expect(data?['lastAction']['type'], 'clearPlayedCards');
      });
    });

    group('Round Management', () {
      test('startNewRound resets round state in Firestore', () async {
        final roomId = 'room5';
        final roundNumber = 2;

        await sync.startNewRound(roomId, roundNumber);

        final snapshot = await fakeFirestore
            .collection('rooms')
            .doc(roomId)
            .get();
        final data = snapshot.data();

        expect(data?['gameState']['roundNumber'], roundNumber);
        expect(data?['gameState']['trump'], null);
        expect(data?['gameState']['trumpRevealed'], false);
        expect(data?['gameState']['playedCards'], {});
        expect(data?['gameState']['currentTurn'], 0);
        expect(data?['lastAction']['type'], 'startNewRound');
      });

      test('endGame marks room as finished in Firestore', () async {
        final roomId = 'room7';

        await sync.endGame(roomId);

        final snapshot = await fakeFirestore
            .collection('rooms')
            .doc(roomId)
            .get();
        final data = snapshot.data();

        expect(data?['status'], 'finished');
        expect(data?['lastAction']['type'], 'endGame');
      });
    });

    group('Scores', () {
      test(
        'updateScores writes team scores to Firestore and restores correctly',
        () async {
          final roomId = 'room6';
          final teamScores = {1: 7, 2: 0};

          await sync.updateScores(roomId, teamScores);

          final snapshot = await fakeFirestore
              .collection('rooms')
              .doc(roomId)
              .get();
          final data = snapshot.data();

          final storedScores = Map<String, dynamic>.from(
            data?['gameState']['teamScores'],
          );
          expect(storedScores, teamScoresToFirestore(teamScores));

          final restoredScores = parseTeamScores(storedScores);
          expect(restoredScores, teamScores);
        },
      );

      test('updateScores round-trip works correctly', () async {
        final roomId = 'room8';
        final teamScores = {1: 15, 2: 10};

        await sync.updateScores(roomId, teamScores);

        final snapshot = await fakeFirestore
            .collection('rooms')
            .doc(roomId)
            .get();
        final data = snapshot.data();

        final storedScores = Map<String, dynamic>.from(
          data?['gameState']['teamScores'],
        );
        expect(storedScores, teamScoresToFirestore(teamScores));

        final restoredScores = parseTeamScores(storedScores);
        expect(restoredScores, teamScores);
      });
    });

    group('Players', () {
      test('joinGame adds player to Firestore', () async {
        final roomId = 'roomJoin';
        final playerData = {'id': 'p1', 'name': 'Alice', 'teamId': 1};

        await sync.joinGame(roomId, playerData);

        final snapshot = await fakeFirestore
            .collection('rooms')
            .doc(roomId)
            .collection('players')
            .doc('p1')
            .get();

        expect(snapshot.exists, true);
        expect(snapshot.data()?['name'], 'Alice');
      });

      test('leaveGame removes player from Firestore', () async {
        final roomId = 'roomLeave';
        final playerData = {'id': 'p2', 'name': 'Bob', 'teamId': 2};

        await sync.joinGame(roomId, playerData);
        await sync.leaveGame(roomId, 'p2');

        final snapshot = await fakeFirestore
            .collection('rooms')
            .doc(roomId)
            .collection('players')
            .doc('p2')
            .get();

        expect(snapshot.exists, false);
      });
    });

    group('Integration', () {
      test('GameState.fromMap restores teamScores field', () {
        final players = [
          Player(id: 1, name: 'Alice', teamId: 1),
          Player(id: 2, name: 'Bob', teamId: 2),
        ];

        final firestoreMap = {
          'roundNumber': 2,
          'highestBidder': 1,
          'trump': 'hearts',
          'trumpRevealed': true,
          'currentTurn': 1,
          'targetScore': 29,
          'tricksHistory': [],
          'teamScores': {'1': 42, '2': 28},
        };

        final gameState = GameState.fromMap(firestoreMap, players);

        expect(gameState.roundNumber, 2);
        expect(gameState.trumpRevealed, true);
        expect(gameState.teamScores[1], 42);
        expect(gameState.teamScores[2], 28);
      });

      test('GameState.toMap writes teamScores with string keys', () {
        final players = [
          Player(id: 1, name: 'Alice', teamId: 1)..score = 10,
          Player(id: 2, name: 'Bob', teamId: 2)..score = 5,
        ];

        final gameState = GameState(players, roundNumber: 1);
        final map = gameState.toMap();

        final teamScores = map['teamScores'] as Map<String, dynamic>;
        expect(teamScores['1'], 10);
        expect(teamScores['2'], 5);
      });

      test(
        'end-to-end: FirestoreSync.updateScores -> GameState.fromMap restores teamScores',
        () async {
          final roomId = 'room9';
          final teamScores = {1: 20, 2: 15};

          await sync.updateScores(roomId, teamScores);

          final snapshot = await fakeFirestore
              .collection('rooms')
              .doc(roomId)
              .get();
          final data = snapshot.data();

          final players = [
            Player(id: 1, name: 'Alice', teamId: 1),
            Player(id: 2, name: 'Bob', teamId: 2),
          ];

          final gameState = GameState.fromMap(
            Map<String, dynamic>.from(data?['gameState']),
            players,
          );

          expect(gameState.teamScores[1], 20);
          expect(gameState.teamScores[2], 15);
        },
      );

      test(
        'end-to-end: FirestoreSync.startNewRound -> GameState.fromMap resets round state',
        () async {
          final roomId = 'room10';
          await sync.startNewRound(roomId, 3);

          final snapshot = await fakeFirestore
              .collection('rooms')
              .doc(roomId)
              .get();
          final data = snapshot.data();

          final players = [
            Player(id: 1, name: 'Alice', teamId: 1),
            Player(id: 2, name: 'Bob', teamId: 2),
          ];

          final gameState = GameState.fromMap(
            Map<String, dynamic>.from(data?['gameState']),
            players,
          );

          expect(gameState.roundNumber, 3);
          expect(gameState.trump, null);
          expect(gameState.trumpRevealed, false);
          expect(gameState.currentTurn, 0);
          expect(gameState.teamScores.isEmpty, true);
        },
      );
    });
  });
}
