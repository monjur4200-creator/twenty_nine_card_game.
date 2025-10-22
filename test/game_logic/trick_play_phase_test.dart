// test/game_logic/trick_play_phase_test.dart
import 'package:test/test.dart';
import 'package:twenty_nine_card_game/game_logic/phases/trick_play_phase.dart';
import 'package:twenty_nine_card_game/game_logic/validation/trick_play_validator.dart';
import 'package:twenty_nine_card_game/game_logic/state_machine/game_phase_machine.dart';
import 'package:twenty_nine_card_game/game_logic/phases/phase.dart';
import '../test_utils.dart'; // ✅ used for error matchers

void main() {
  group('TrickPlayPhase', () {
    TrickPlayPhase makePhase() =>
        TrickPlayPhase(validator: const TrickPlayValidator());

    GameState makeState({
      required List<String> ids,
      required List<List<Card>> hands,
      int currentIndex = 0,
      String? trumpSuit,
      Trick? trick,
    }) {
      final players = [
        for (var i = 0; i < ids.length; i++)
          PlayerState(id: ids[i], hand: hands[i]),
      ];
      return GameState(
        players: players,
        currentPlayerIndex: currentIndex,
        currentTrick: trick ?? const Trick(),
        trumpSuit: trumpSuit,
      );
    }

    test('plays a lead card and advances turn', () {
      final phase = makePhase();
      final cardA = Card('S', 10);
      final state = makeState(
        ids: ['A', 'B', 'C', 'D'],
        hands: [
          [cardA],
          [Card('H', 9)],
          [Card('D', 8)],
          [Card('C', 7)],
        ],
      );

      final machine = GamePhaseMachine<GameState>(initialState: state);
      machine.start(phase);

      machine.dispatch(
        PhaseAction(
          'play_card',
          payload: {
            'playerId': 'A',
            'card': cardA, // ✅ reuse same instance
          },
        ),
      );

      expect(machine.state.currentTrick.leadSuit, equals('S'));
      expect(machine.state.currentTrick.plays.length, equals(1));
      expect(machine.state.currentPlayer.id, equals('B'));
    });

    test('rejects out-of-turn play', () {
      final phase = makePhase();
      final cardA = Card('S', 10);
      final cardB = Card('H', 9);
      final state = makeState(
        ids: ['A', 'B', 'C', 'D'],
        hands: [
          [cardA],
          [cardB],
          [Card('D', 8)],
          [Card('C', 7)],
        ],
      );
      final machine = GamePhaseMachine<GameState>(initialState: state);
      machine.start(phase);

      expect(
        () => machine.dispatch(
          PhaseAction(
            'play_card',
            payload: {
              'playerId': 'B', // should be A
              'card': cardB,
            },
          ),
        ),
        throwsOutOfTurn(),
      );
    });

    test('requires following lead suit when possible', () {
      final phase = makePhase();
      final cardA = Card('S', 10);
      final cardB1 = Card('S', 9);
      final cardB2 = Card('H', 2);
      final state = makeState(
        ids: ['A', 'B', 'C', 'D'],
        hands: [
          [cardA],
          [cardB1, cardB2],
          [Card('D', 8)],
          [Card('C', 7)],
        ],
      );
      final machine = GamePhaseMachine<GameState>(initialState: state);
      machine.start(phase);

      // A leads spade
      machine.dispatch(
        PhaseAction('play_card', payload: {'playerId': 'A', 'card': cardA}),
      );

      // B must follow spade
      expect(
        () => machine.dispatch(
          PhaseAction(
            'play_card',
            payload: {
              'playerId': 'B',
              'card': cardB2, // tries to play hearts instead of spade
            },
          ),
        ),
        throwsSuitFollowRequired(),
      );
    });

    test('completes trick, picks winner, and sets next leader', () {
      final phase = makePhase();
      final cardA = Card('S', 10);
      final cardB = Card('S', 11);
      final cardC = Card('H', 12);
      final cardD = Card('S', 9);
      final state = makeState(
        ids: ['A', 'B', 'C', 'D'],
        hands: [
          [cardA],
          [cardB],
          [cardC],
          [cardD],
        ],
      );

      final machine = GamePhaseMachine<GameState>(initialState: state);
      machine.start(phase);

      machine.dispatch(
        PhaseAction('play_card', payload: {'playerId': 'A', 'card': cardA}),
      );
      machine.dispatch(
        PhaseAction('play_card', payload: {'playerId': 'B', 'card': cardB}),
      );
      machine.dispatch(
        PhaseAction('play_card', payload: {'playerId': 'C', 'card': cardC}),
      );
      machine.dispatch(
        PhaseAction('play_card', payload: {'playerId': 'D', 'card': cardD}),
      );

      // Complete phase: winner should be B with highest spade (11)
      machine.completeActivePhase();
      expect(machine.activePhase, isNull);
      expect(machine.state.currentTrick.plays.length, equals(0)); // reset
      expect(machine.state.currentPlayer.id, equals('B')); // next leader
    });
  });
}
