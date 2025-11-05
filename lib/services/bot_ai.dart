import '../models/card29.dart' as model; // Card29 + Suit + Rank
import '../models/game_state.dart';
import '../models/player.dart';

enum BotPersonality { aggressive, cautious, logical }

class BotAI {
  final BotPersonality personality;
  final List<model.Card29> memory = [];

  BotAI(this.personality);

  void remember(model.Card29 card) => memory.add(card);

  model.Card29 playCard(GameState state, Player player) {
    switch (personality) {
      case BotPersonality.aggressive:
        return _playAggressive(state, player);
      case BotPersonality.cautious:
        return _playCautious(state, player);
      case BotPersonality.logical:
        return _playLogical(state, player);
    }
  }

  // --- Aggressive: prefers highest trump, else highest overall ---
  model.Card29 _playAggressive(GameState state, Player player) {
    final legalMoves = _legalMoves(state, player);
    final trumpSuit = state.trump;

    if (trumpSuit != null) {
      final trumpCards = _sortedByRank(
        legalMoves.where((c) => c.suit == trumpSuit),
        descending: true,
      );
      if (trumpCards.isNotEmpty) return trumpCards.first;
    }

    return _sortedByRank(legalMoves, descending: true).first;
  }

  // --- Cautious: conserve strength if partner is winning ---
  model.Card29 _playCautious(GameState state, Player player) {
    final legalMoves = _legalMoves(state, player);
    final currentWinner = state.lastTrick?.determineWinner(state.trump);

    if (currentWinner != null && currentWinner.teamId == player.teamId) {
      return _sortedByRank(legalMoves).first;
    }

    return _sortedByRank(legalMoves).first;
  }

  // --- Logical: follow suit > trump > lowest discard ---
  model.Card29 _playLogical(GameState state, Player player) {
    final legalMoves = _legalMoves(state, player);
    final leadSuit = state.lastTrick?.leadSuit;
    final trumpSuit = state.trump;

    if (leadSuit != null) {
      final followSuitCards =
          _sortedByRank(legalMoves.where((c) => c.suit == leadSuit));
      if (followSuitCards.isNotEmpty) return followSuitCards.first;
    }

    if (trumpSuit != null) {
      final trumpCards = _sortedByRank(
        legalMoves.where((c) => c.suit == trumpSuit),
        descending: true,
      );
      if (trumpCards.isNotEmpty) return trumpCards.first;
    }

    return _sortedByRank(legalMoves).first;
  }

  // --- Helper: filter legal moves ---
  List<model.Card29> _legalMoves(GameState state, Player player) {
    final legalMoves = player.hand.where(state.isLegalMove).toList();
    if (legalMoves.isEmpty) {
      throw StateError('No legal moves available for ${player.name}');
    }
    return legalMoves;
  }

  // --- Helper: sort cards by rank ---
  List<model.Card29> _sortedByRank(
    Iterable<model.Card29> cards, {
    bool descending = false,
  }) {
    final list = cards.toList();
    list.sort((a, b) => descending
        ? b.rank.index.compareTo(a.rank.index)
        : a.rank.index.compareTo(b.rank.index));
    return list;
  }
}
