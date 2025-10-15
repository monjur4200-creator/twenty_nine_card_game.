import 'card.dart';
import 'player.dart';
import 'trick.dart';

class GameState {
  List<Player> players = [];
  Suit? trump;
  int currentTurn = 0;
  List<Trick> tricks = [];

  GameState(this.players);

  Player get currentPlayer => players[currentTurn];

  void nextTurn() {
    currentTurn = (currentTurn + 1) % players.length;
  }

  void dealCards() {
    var deck = Card29.fullDeck()..shuffle();
    for (int i = 0; i < players.length; i++) {
      players[i].hand = deck.sublist(i * 8, (i + 1) * 8);
    }
  }
}