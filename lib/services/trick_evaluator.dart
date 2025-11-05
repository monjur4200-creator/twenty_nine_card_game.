import 'package:twenty_nine_card_game/models/card29.dart';

/// Evaluates tricks according to Twenty-Nine rules.
class TrickEvaluator {
  final Suit trumpSuit;

  TrickEvaluator({required this.trumpSuit});

  /// Rank order for 29: J > 9 > A > 10 > K > Q > 8 > 7
  static const List<Rank> rankOrder = [
    Rank.jack,
    Rank.nine,
    Rank.ace,
    Rank.ten,
    Rank.king,
    Rank.queen,
    Rank.eight,
    Rank.seven,
  ];

  /// Returns the winner's owner name from a trick pile.
  String determineWinner(List<Card29> trickPile) {
    if (trickPile.isEmpty) return "No one";

    final leadingSuit = trickPile.first.suit;

    int rankIndex(Rank rank) =>
        rankOrder.contains(rank) ? rankOrder.indexOf(rank) : rankOrder.length;

    // Filter trump cards
    final trumps = trickPile.where((c) => c.suit == trumpSuit).toList();
    if (trumps.isNotEmpty) {
      trumps.sort((a, b) => rankIndex(a.rank).compareTo(rankIndex(b.rank)));
      return trumps.first.owner ?? "Unknown";
    }

    // Filter leading suit cards
    final leads = trickPile.where((c) => c.suit == leadingSuit).toList();
    leads.sort((a, b) => rankIndex(a.rank).compareTo(rankIndex(b.rank)));
    return leads.first.owner ?? "Unknown";
  }
}
