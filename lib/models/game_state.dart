import 'player.dart';
import 'card.dart';
import 'trick.dart';

/// Represents the overall state of a single game session.
class GameState {
  final List<Player> players;

  int roundNumber = 1;
  Player? highestBidder;
  Suit? trump;
  bool trumpRevealed = false;
  int currentTurn = 0;

  /// Target score for the bidding team (default 29).
  int targetScore = 29;

  /// Keeps a history of tricks played.
  final List<Trick> tricksHistory = [];

  GameState(this.players);

  // --- Round Management ---

  /// Starts a new round by resetting per-round state.
  void startNewRound() {
    for (var player in players) {
      player.tricksWon = 0;
      player.score = 0;
      player.resetForNewRound();
    }
    trump = null;
    trumpRevealed = false;
    currentTurn = 0;
    roundNumber++;
    tricksHistory.clear();
  }

  // --- Bidding ---

  /// Conducts bidding and determines the highest bidder.
  void conductBidding(Map<Player, int> bids) {
    if (bids.isEmpty) {
      throw ArgumentError('No bids were placed.');
    }

    Player? topBidder;
    int highestBid = 0;

    bids.forEach((player, bid) {
      if (bid > highestBid) {
        highestBid = bid;
        topBidder = player;
      }
    });

    highestBidder = topBidder;
    targetScore = highestBid; // update target score to winning bid
  }

  // --- Trump ---

  /// Reveals the trump suit.
  void revealTrump(Suit suit) {
    if (trumpRevealed) {
      throw ArgumentError('Trump has already been revealed.');
    }
    trump = suit;
    trumpRevealed = true;
  }

  // --- Gameplay ---

  /// Plays a card for a player and records it in the current trick.
  /// When the trick is complete, determines the winner and awards points.
  void playCard(Player player, Card29 card) {
    // Start a new trick if needed
    if (tricksHistory.isEmpty || tricksHistory.last.plays.length == players.length) {
      tricksHistory.add(Trick());
    }

    final currentTrick = tricksHistory.last;
    currentTrick.addPlay(player, card);

    // If trick is complete (all players have played), resolve it
    if (currentTrick.plays.length == players.length) {
      final winner = currentTrick.determineWinner(trump);
      if (winner != null) {
        winner.tricksWon += 1;
        winner.score += currentTrick.totalPoints();
      }
    }
  }

  /// Total tricks taken across all players.
  int get tricks => players.fold(0, (sum, p) => sum + p.tricksWon);

  /// The most recent trick played (if any).
  Trick? get lastTrick => tricksHistory.isNotEmpty ? tricksHistory.last : null;

  // --- Scoring ---

  /// Calculates team scores by summing player scores.
  Map<int, int> calculateTeamScores() {
    final scores = <int, int>{};
    for (var player in players) {
      scores[player.teamId] = (scores[player.teamId] ?? 0) + player.score;
    }
    return scores;
  }

  /// Exposes team scores as a getter for convenience.
  Map<int, int> get teamScores => calculateTeamScores();

  /// Determines if the bidding team won.
  bool didBiddingTeamWin() {
    if (highestBidder == null) return false;
    final scores = calculateTeamScores();
    final biddingTeam = highestBidder!.teamId;
    final opponentTeam = biddingTeam == 1 ? 2 : 1;

    return (scores[biddingTeam] ?? 0) >= (scores[opponentTeam] ?? 0);
  }

  /// Debug/console summary of the round.
  void printRoundSummary() {
    for (var player in players) {
      // ignore: avoid_print
      print('${player.name}: Tricks ${player.tricksWon}, Score ${player.score}');
    }
    // ignore: avoid_print
    print('Team Scores: $teamScores');
  }

  // --- Serialization ---

  /// Serializes the game state for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'roundNumber': roundNumber,
      'highestBidder': highestBidder?.id,
      'trump': trump?.name,
      'trumpRevealed': trumpRevealed,
      'currentTurn': currentTurn,
      'targetScore': targetScore,
      'players': players.map((p) => p.toMap()).toList(),
      'tricksHistory': tricksHistory.map((t) => t.toMap()).toList(),
    };
  }

  /// Deserializes the game state from Firestore.
  factory GameState.fromMap(
    Map<String, dynamic> map,
    List<Player> allPlayers,
  ) {
    final round = map['roundNumber'] ?? 1;
    final trumpName = map['trump'];
    final trumpSuit = trumpName != null ? Suit.values.byName(trumpName) : null;

    final tricks = (map['tricksHistory'] as List<dynamic>? ?? [])
        .map((trickMap) => Trick.fromMap(
              Map<String, dynamic>.from(trickMap),
              allPlayers,
            ))
        .toList();

    return GameState(allPlayers)
      ..roundNumber = round
      ..highestBidder = allPlayers.firstWhere(
        (p) => p.id == map['highestBidder'],
        orElse: () => allPlayers.first,
      )
      ..trump = trumpSuit
      ..trumpRevealed = map['trumpRevealed'] ?? false
      ..currentTurn = map['currentTurn'] ?? 0
      ..targetScore = map['targetScore'] ?? 29
      ..tricksHistory.addAll(tricks);
  }
}