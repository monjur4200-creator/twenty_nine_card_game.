import 'card.dart';
import 'player.dart';

class Trick {
  final Map<Player, Card29> plays = {};

  void addPlay(Player player, Card29 card) {
    plays[player] = card;
  }

  // Winner logic will be added later
}