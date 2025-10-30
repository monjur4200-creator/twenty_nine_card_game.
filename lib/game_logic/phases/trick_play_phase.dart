// lib/game_logic/phases/trick_play_phase.dart
import 'package:collection/collection.dart';
import '../validation/trick_play_validator.dart';
import '../game_errors.dart';
import 'phase.dart';

/// Minimal types to keep this file self-contained.
/// You can replace these with your actual models later.
class Card {
  final String suit; // 'S','H','D','C'
  final int rank; // 2..14 (Ace=14)
  Card(this.suit, this.rank);
}

class PlayerState {
  final String id;
  final List<Card> hand;
  PlayerState({required this.id, required this.hand});

  PlayerState removeCard(Card c) =>
      PlayerState(id: id, hand: hand.whereNot((x) => x == c).toList());
}

class Trick {
  final String? leadSuit;
  final List<Map<String, Object?>> plays; // [{playerId, card}]
  Trick({this.leadSuit, this.plays = const []});

  Trick addPlay(String playerId, Card card) {
    final newLeadSuit = leadSuit ?? card.suit;
    return Trick(
      leadSuit: newLeadSuit,
      plays: [
        ...plays,
        {'playerId': playerId, 'card': card},
      ],
    );
  }

  bool get isComplete => plays.length >= 4;
}

class GameState {
  final List<PlayerState> players; // order defines turn rotation
  final int currentPlayerIndex;
  final Trick currentTrick;
  final String? trumpSuit;

  GameState({
    required this.players,
    required this.currentPlayerIndex,
    required this.currentTrick,
    this.trumpSuit,
  });

  PlayerState get currentPlayer => players[currentPlayerIndex];

  GameState withPlayers(List<PlayerState> next) => GameState(
    players: next,
    currentPlayerIndex: currentPlayerIndex,
    currentTrick: currentTrick,
    trumpSuit: trumpSuit,
  );

  GameState advanceTurn() => GameState(
    players: players,
    currentPlayerIndex: (currentPlayerIndex + 1) % players.length,
    currentTrick: currentTrick,
    trumpSuit: trumpSuit,
  );

  GameState withTrick(Trick t) => GameState(
    players: players,
    currentPlayerIndex: currentPlayerIndex,
    currentTrick: t,
    trumpSuit: trumpSuit,
  );
}

/// TrickPlayPhase: handles card plays during trick-taking.
class TrickPlayPhase extends Phase<GameState> {
  final TrickPlayValidator validator;
  bool _active = false;

  TrickPlayPhase({TrickPlayValidator? validator})
    : validator = validator ?? TrickPlayValidator();

  @override
  String get name => 'TrickPlay';

  @override
  bool get isActive => _active;

  @override
  void start(GameState state) {
    _active = true;
    // Optional: sanity checks (e.g., hands not empty)
  }

  @override
  GameState handleAction(GameState state, PhaseAction action) {
    if (!_active) {
      throw GameError.invalidMove('Phase not active', ctx: {'phase': name});
    }
    if (action.type != 'play_card') {
      throw GameError.invalidMove(
        'Unsupported action',
        ctx: {'type': action.type},
      );
    }

    final playerId = action.payload['playerId'] as String?;
    final card = action.payload['card'] as Card?;
    if (playerId == null || card == null) {
      throw GameError.invalidMove('Missing payload: playerId or card');
    }

    // Turn check
    if (state.currentPlayer.id != playerId) {
      throw GameError.outOfTurn(
        playerId,
        ctx: {'expected': state.currentPlayer.id, 'phase': name},
      );
    }

    // Validation
    validator.ensureLegalPlay(state: state, playerId: playerId, card: card);

    // Apply play
    final updatedTrick = state.currentTrick.addPlay(playerId, card);
    final updatedPlayers = state.players
        .map((p) => p.id == playerId ? p.removeCard(card) : p)
        .toList();

    final playedState = state
        .withPlayers(updatedPlayers)
        .withTrick(updatedTrick);

    // Advance turn if trick not complete
    return updatedTrick.isComplete ? playedState : playedState.advanceTurn();
  }

  @override
  GameState complete(GameState state) {
    if (!state.currentTrick.isComplete) {
      throw GameError.invalidMove('Cannot complete: trick incomplete');
    }
    _active = false;

    // Decide trick winner (simplified: highest rank of lead suit or trump)
    final lead = state.currentTrick.leadSuit;
    final trump = state.trumpSuit;

    Map<String, Object?>? winningPlay;
    int bestScore = -1;

    for (final play in state.currentTrick.plays) {
      final card = play['card'] as Card;
      final isTrump = trump != null && card.suit == trump;
      final followsLead = card.suit == lead;

      final score = isTrump ? (100 + card.rank) : (followsLead ? card.rank : 0);
      if (score > bestScore) {
        bestScore = score;
        winningPlay = play;
      }
    }

    // Move turn to winner for next lead.
    final winnerId = winningPlay?['playerId'] as String?;
    final winnerIndex = state.players.indexWhere((p) => p.id == winnerId);
    if (winnerIndex == -1) {
      // Fallback: keep current
      return GameState(
        players: state.players,
        currentPlayerIndex: state.currentPlayerIndex,
        currentTrick: Trick(), // reset for next trick
        trumpSuit: state.trumpSuit,
      );
    }

    return GameState(
      players: state.players,
      currentPlayerIndex: winnerIndex,
      currentTrick: Trick(), // reset for next trick
      trumpSuit: state.trumpSuit,
    );
  }
}
