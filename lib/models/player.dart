import 'card.dart';

class Player {
  final String name;
  List<Card29> hand = [];
  int score = 0;

  Player(this.name);

  void playCard(Card29 card) {
    hand.remove(card);
  }

  @override
  String toString() => name;
}