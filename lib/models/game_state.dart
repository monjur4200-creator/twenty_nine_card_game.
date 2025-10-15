import 'card.dart';
import 'player.dart';
import 'trick.dart';

class GameState {
  List<Player> players;
  Suit? trump;
  bool trumpRevealed = false;
  int currentTurn = 0;
  int dealerIndex = 0;
  int roundNumber = 1;

  List<Trick> tricks = [];
  Trick currentTrick = Trick();

  Player? highestBidder;
  int? targetScore;

  GameState(this.players) {
    assignDealer();
  }

  Player get currentPlayer => players[currentTurn];
  Player get dealer => players[dealerIndex];

  /// Assigns dealer for the round
  void assignDealer() {
    for (var player in players) {
      player.isDealer = false;
    }
    players[dealerIndex].isDealer = true;
  }

  /// Advances turn to next player
  void nextTurn() {
    currentTurn = (currentTurn + 1) % players.length;
  }

  /// Shuffles and deals cards to all players
  void dealCards() {
    var deck = Card29.fullDeck()..shuffle();
    for (int i = 0; i < players.length; i++) {
      players[i].receiveCards(deck.sublist(i * 8, (i + 1) * 8));
      players[i].sortHand();
    }
  }

  /// Reveals trump suit and marks trump cards
  void revealTrump(Suit suit) {
    trump = suit;
    trumpRevealed = true;

    for (var player in players) {
      for (var card in player.hand) {
        card.isTrump = (card.suit == suit);
      }
    }
  }

  /// Handles bidding phase and sets highest bidder
  void conductBidding(Map<Player, int> bids) {
    Player? topBidder;
    int highest = 0;

    bids.forEach((player, bid) {
      player.placeBid(bid);
      if (bid > highest) {
        highest = bid;
        topBidder = player;
      }
    });

    highestBidder = topBidder;
    targetScore = highest;
  }

  /// Plays a card and updates trick state
  void playCard(Player player, Card29 card) {
    player.playCard(card);
    currentTrick.addPlay(player, card);

    if (currentTrick.plays.length == players.length) {
      finalizeTrick();
    } else {
      nextTurn();
    }
  }

  /// Finalizes a trick and updates winner
  void finalizeTrick() {
    final winner = currentTrick.determineWinner(trump?.name ?? '');
    if (winner != null) {
      winner.tricksWon++;
      currentTurn = players.indexOf(winner);
    }
    tricks.add(currentTrick);
    currentTrick = Trick();
  }

  /// Starts a new round and resets state
  void startNewRound() {
    roundNumber++;
    trump = null;
    trumpRevealed = false;
    tricks.clear();
    currentTrick = Trick();
    highestBidder = null;
    targetScore = null;

    for (var player in players) {
      player.resetForNewRound();
    }

    dealerIndex = (dealerIndex + 1) % players.length;
    assignDealer();
    currentTurn = (dealerIndex + 1) % players.length;

    dealCards();
  }

  /// Calculates individual scores based on tricks won
  Map<Player, int> calculateScores() {
    final scores = <Player, int>{};
    for (var player in players) {
      scores[player] = 0;
    }
    for (var trick in tricks) {
      final winner = trick.determineWinner(trump?.name ?? '');
      if (winner != null) {
        scores[winner] = scores[winner]! + trick.totalPoints();
      }
    }
    return scores;
  }

  /// Calculates team scores based on trick winners
  Map<int, int> calculateTeamScores() {
    final teamScores = {1: 0, 2: 0};
    for (var trick in tricks) {
      final winner = trick.determineWinner(trump?.name ?? '');
      if (winner != null) {
        teamScores[winner.teamId] = teamScores[winner.teamId]! + trick.totalPoints();
      }
    }
    return teamScores;
  }

  /// Checks if the bidding team met their target score
  bool didBiddingTeamWin() {
    if (highestBidder == null || targetScore == null) return false;
    final teamScores = calculateTeamScores();
    final biddingTeam = highestBidder!.teamId;
    return teamScores[biddingTeam]! >= targetScore!;
  }

  /// Prints round summary for all players and teams
  void printRoundSummary() {
    print("Round $roundNumber Summary:");
    for (var player in players) {
      print("${player.name} - Tricks: ${player.tricksWon}, Score: ${player.score}");
    }

    final teamScores = calculateTeamScores();
    print("Team 1 Score: ${teamScores[1]}");
    print("Team 2 Score: ${teamScores[2]}");

    if (highestBidder != null) {
      final biddingTeam = highestBidder!.teamId;
      final result = didBiddingTeamWin() ? "WON" : "LOST";
      print("Bidding Team ($biddingTeam) $result the round!");
    }
  }
}