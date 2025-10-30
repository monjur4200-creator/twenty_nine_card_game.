import '../game_errors.dart';
import '../phases/trick_play_phase.dart' show GameState, Card;

class TrickPlayValidator {
  TrickPlayValidator();

  void ensureLegalPlay({
    required GameState state,
    required String playerId,
    required Card card,
  }) {
    final player = state.players.firstWhere(
      (p) => p.id == playerId,
      orElse: () => throw GameError.invalidMove('Unknown player: $playerId'),
    );

    if (!player.hand.contains(card)) {
      throw GameError(
        code: GameErrorCode.cardNotInHand,
        message: 'Card not in hand',
        context: {'playerId': playerId, 'card': '${card.suit}${card.rank}'},
      );
    }

    final lead = state.currentTrick.leadSuit;
    if (lead != null && card.suit != lead) {
      final canFollowLead = player.hand.any((c) => c.suit == lead);
      if (canFollowLead) {
        throw GameError(
          code: GameErrorCode.suitFollowRequired,
          message: 'Must follow lead suit',
          context: {'leadSuit': lead, 'playedSuit': card.suit},
        );
      }
    }
  }
}
