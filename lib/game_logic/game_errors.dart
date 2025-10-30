// lib/game_logic/game_errors.dart

/// Enumerates all possible error codes for the game logic.
enum GameErrorCode {
  invalidMove,
  outOfTurn,
  cardNotInHand,
  suitFollowRequired,
  trumpIllegalReveal,
  bidOutOfRange,
  stateTransitionBlocked,
  unknown,
}

/// A structured exception type used throughout the game logic.
/// Provides a code, human-readable message, and optional context.
class GameError implements Exception {
  final GameErrorCode code;
  final String message;
  final Map<String, Object?> context;

  GameError({
    required this.code,
    required this.message,
    this.context = const {},
  });

  @override
  String toString() =>
      'GameError(code: $code, message: $message, context: $context)';

  // --- Factory constructors for common errors ---

  factory GameError.invalidMove(
    String reason, {
    Map<String, Object?> ctx = const {},
  }) {
    return GameError(
      code: GameErrorCode.invalidMove,
      message: reason,
      context: ctx,
    );
  }

  factory GameError.outOfTurn(
    String playerId, {
    Map<String, Object?> ctx = const {},
  }) {
    return GameError(
      code: GameErrorCode.outOfTurn,
      message: 'Out of turn: $playerId',
      context: {'playerId': playerId, ...ctx},
    );
  }

  factory GameError.cardNotInHand({
    required String playerId,
    required String card,
    Map<String, Object?> ctx = const {},
  }) {
    return GameError(
      code: GameErrorCode.cardNotInHand,
      message: 'Player $playerId does not have card $card',
      context: {'playerId': playerId, 'card': card, ...ctx},
    );
  }

  factory GameError.suitFollowRequired({
    required String playerId,
    required String suit,
    Map<String, Object?> ctx = const {},
  }) {
    return GameError(
      code: GameErrorCode.suitFollowRequired,
      message: 'Player $playerId must follow suit $suit',
      context: {'playerId': playerId, 'suit': suit, ...ctx},
    );
  }

  factory GameError.trumpIllegalReveal({
    required String playerId,
    Map<String, Object?> ctx = const {},
  }) {
    return GameError(
      code: GameErrorCode.trumpIllegalReveal,
      message: 'Player $playerId attempted an illegal trump reveal',
      context: {'playerId': playerId, ...ctx},
    );
  }

  factory GameError.bidOutOfRange({
    required String playerId,
    required int bid,
    Map<String, Object?> ctx = const {},
  }) {
    return GameError(
      code: GameErrorCode.bidOutOfRange,
      message: 'Player $playerId placed an out-of-range bid: $bid',
      context: {'playerId': playerId, 'bid': bid, ...ctx},
    );
  }

  factory GameError.stateTransitionBlocked({
    required String reason,
    Map<String, Object?> ctx = const {},
  }) {
    return GameError(
      code: GameErrorCode.stateTransitionBlocked,
      message: 'State transition blocked: $reason',
      context: ctx,
    );
  }

  factory GameError.unknown([String message = 'Unknown error']) {
    return GameError(code: GameErrorCode.unknown, message: message);
  }
}
