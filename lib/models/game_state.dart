import 'player.dart';
import 'card.dart';
import 'trick.dart';
import 'package:twenty_nine_card_game/models/utils/firestore_helpers.dart';
import 'package:twenty_nine_card_game/game_logic/game_errors.dart';

/// Represents the overall state of a single game session.
class GameState {
  final List<Player> players;

  int roundNumber;
  Player? highestBidder;
  Suit? trump;
  bool trumpRevealed;
  int currentTurn;

  /// Target score for the bidding team (default 29).
  int targetScore;

  /// Keeps a history of tricks played.
  final List<Trick> tricksHistory;

  /// Stores team scores (int keys) for quick access.
  Map<int, int> teamScores;

  GameState(
    this.players, {
    this.roundNumber = 1,
    this.highestBidder,
    this.trump,
    this.trumpRevealed = false,
    this.currentTurn = 0,
    this.targetScore = 29,
    List<Trick>? tricksHistory,
    Map<int, int>? teamScores,
  })  : tricksHistory = tricksHistory ?? [],
        teamScores = teamScores ?? {};

  // --- Round Management ---

  void startNewRound() {
    roundNumber++;

    // Purge any empty tricks left over
    tricksHistory.removeWhere((t) => t.plays.isEmpty);
    tricksHistory.clear();

    highestBidder = null;
    trump = null;
    trumpRevealed = false;
    currentTurn = 0;

    for (final p in players) {
      p.resetForNewRound();
    }
  }

  // --- Bidding ---

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
    targetScore = highestBid;
  }

  // --- Trump ---

  void revealTrump(Suit suit) {
    if (trumpRevealed) {
      throw ArgumentError('Trump has already been revealed.');
    }
    trump = suit;
    trumpRevealed = true;
  }

  // --- Gameplay ---

  void playCard(Player player, Card29 card) {
    // ✅ Guard: player must actually have the card
    if (!player.hand.contains(card)) {
      throw GameError.cardNotInHand(
        playerId: player.id.toString(),
        card: card.toString(),
      );
    }

    // Start a new trick only if the last one is complete
    if (tricksHistory.isEmpty ||
        tricksHistory.last.plays.length == players.length) {
      // Don’t create a trick if the player has no cards left (end of round)
      if (player.hand.isEmpty) return;
      tricksHistory.add(Trick());
    }

    final currentTrick = tricksHistory.last;
    currentTrick.addPlay(player, card);

    // ✅ If trick is complete, determine winner and award points
    if (currentTrick.plays.length == players.length) {
      final winner = currentTrick.determineWinner(trump);
      if (winner != null) {
        winner.tricksWon += 1;
        winner.score += currentTrick.totalPoints();
      }
    }

    // ✅ After the last card of the round, purge any empty trick
    if (players.every((p) => p.hand.isEmpty)) {
      tricksHistory.removeWhere((t) => t.plays.isEmpty);
    }
  }

  /// Returns the most recent trick, or null if none exist.
  Trick? get lastTrick =>
      tricksHistory.isNotEmpty ? tricksHistory.last : null;

  // --- Scoring ---

  /// Pure calculation of team scores (does not mutate state).
  Map<int, int> calculateTeamScores() {
    final scores = <int, int>{};
    for (var player in players) {
      scores[player.teamId] = (scores[player.teamId] ?? 0) + player.score;
    }
    return scores;
  }

  /// Recalculate and update teamScores field.
  void updateTeamScores() {
    teamScores = calculateTeamScores();
  }

  /// Check if bidding team met their target score.
  bool didBiddingTeamWin() {
    if (highestBidder == null) return false;
    updateTeamScores();
    final biddingTeam = highestBidder!.teamId;
    return (teamScores[biddingTeam] ?? 0) >= targetScore;
  }

  void printRoundSummary() {
    // ignore: avoid_print
    print('Round $roundNumber Summary');

    for (var player in players) {
      // ignore: avoid_print
      print(
        '${player.name}: Tricks ${player.tricksWon}, Score ${player.score}',
      );
    }
    // ignore: avoid_print
    print('Team Scores: $teamScores');
  }

  // --- Serialization ---

  Map<String, dynamic> toMap() {
    updateTeamScores();
    return {
      'roundNumber': roundNumber,
      'highestBidder': highestBidder?.id,
      'trump': trump?.name,
      'trumpRevealed': trumpRevealed,
      'currentTurn': currentTurn,
      'targetScore': targetScore,
      'players': players.map((p) => p.toMap()).toList(),
      'tricksHistory': tricksHistory.map((t) => t.toMap()).toList(),
      'teamScores': teamScoresToFirestore(teamScores),
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map, List<Player> allPlayers) {
    final round = (map['roundNumber'] as num?)?.toInt() ?? 1;
    final trumpName = map['trump'] as String?;
    final trumpSuit = trumpName != null ? Suit.values.byName(trumpName) : null;

    final tricks = (map['tricksHistory'] as List<dynamic>? ?? [])
        .map(
          (trickMap) =>
              Trick.fromMap(Map<String, dynamic>.from(trickMap), allPlayers),
        )
        .toList();

    final highestBidderId = (map['highestBidder'] as num?)?.toInt();

    final rawScores = map['teamScores'] as Map<String, dynamic>? ?? {};
    final parsedScores = parseTeamScores(rawScores);

    return GameState(
      allPlayers,
      roundNumber: round,
      highestBidder: highestBidderId != null
          ? allPlayers.firstWhere(
              (p) => p.id == highestBidderId,
              orElse: () => allPlayers.first,
            )
          : null,
      trump: trumpSuit,
      trumpRevealed: map['trumpRevealed'] as bool? ?? false,
      currentTurn: (map['currentTurn'] as num?)?.toInt() ?? 0,
      targetScore: (map['targetScore'] as num?)?.toInt() ?? 29,
      tricksHistory: tricks,
      teamScores: parsedScores,
    );
  }

  // --- Game Finalization ---

  /// Clears any leftover tricks at the end of the game.
  void finalizeGame() {
    tricksHistory.clear();
  }
}