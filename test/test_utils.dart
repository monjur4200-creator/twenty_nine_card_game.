import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/game_logic/game_errors.dart';
import 'package:twenty_nine_card_game/models/game_state.dart';
import 'package:twenty_nine_card_game/models/player.dart';

/// --- Error Matchers ---

/// Generic matcher for any [GameError].
Matcher throwsAnyGameError() => throwsA(isA<GameError>());

/// Matcher for a specific [GameErrorCode].
Matcher throwsGameError(GameErrorCode code) {
  return throwsA(isA<GameError>().having((e) => e.code, 'code', code));
}

/// Convenience matchers for common error codes.
Matcher throwsCardNotInHand() => throwsGameError(GameErrorCode.cardNotInHand);

Matcher throwsSuitFollowRequired() =>
    throwsGameError(GameErrorCode.suitFollowRequired);

Matcher throwsOutOfTurn() => throwsGameError(GameErrorCode.outOfTurn);

Matcher throwsInvalidMove() => throwsGameError(GameErrorCode.invalidMove);

/// --- Round Reset Helper ---

/// Asserts that per‑round state has been reset correctly.
/// Use after calling `gameState.startNewRound()`.
void assertRoundReset(GameState gameState, List<Player> players) {
  for (final p in players) {
    expect(p.tricksWon, equals(0));
    expect(p.hand, isEmpty);
    // Note: p.score persists across rounds, so we do NOT reset it here.
  }
  expect(gameState.trump, isNull);
  expect(gameState.trumpRevealed, isFalse);
  expect(gameState.tricksHistory, isEmpty);
  // Team scores persist across rounds, so we only check structure if needed.
}
