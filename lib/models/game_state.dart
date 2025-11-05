import 'package:flutter/foundation.dart';
import 'player.dart';
import 'card29.dart';
import 'trick.dart';
import 'package:twenty_nine_card_game/models/utils/firestore_helpers.dart';
import 'package:twenty_nine_card_game/game_logic/game_errors.dart';

class GameState {
  final List<Player> players;

  int roundNumber;
  Player? highestBidder;
  Suit? trump;
  bool trumpRevealed;
  int currentTurn;
  int targetScore;

  final List<Trick> tricksHistory;
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
    tricksHistory.clear();
    highestBidder = null;
    trump = null;
    trumpRevealed = false;
    currentTurn = 0;
    for (final p in players) {
      p.resetForNewRound();
    }
  }

  // --- Bidding & Trump ---

  void conductBidding(Map<Player, int> bids) {
    if (bids.isEmpty) throw ArgumentError('No bids were placed.');
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

  void revealTrump(Suit suit) {
    if (trumpRevealed) throw ArgumentError('Trump has already been revealed.');
    trump = suit;
    trumpRevealed = true;
  }

  // --- Trick Play ---

  void playCard(Player player, Card29 card) {
    if (!player.hand.contains(card)) {
      throw GameError.cardNotInHand(
        playerId: player.id.toString(),
        card: card.toString(),
      );
    }

    if (tricksHistory.isEmpty || tricksHistory.last.plays.length == players.length) {
      if (player.hand.isEmpty) return;
      tricksHistory.add(Trick());
    }

    final currentTrick = tricksHistory.last;
    currentTrick.addPlay(player, card);

    if (currentTrick.plays.length == players.length) {
      final winner = currentTrick.determineWinner(trump);
      if (winner != null) {
        winner.tricksWon += 1;
        winner.score += currentTrick.totalPoints();
      }
    }

    if (players.every((p) => p.hand.isEmpty)) {
      tricksHistory.removeWhere((t) => t.plays.isEmpty);
    }
  }

  Trick? get lastTrick => tricksHistory.isNotEmpty ? tricksHistory.last : null;
  Trick? get currentTrick => tricksHistory.isNotEmpty ? tricksHistory.last : null;

  Player? getTrickWinner() {
    final trick = lastTrick;
    if (trick == null || trick.plays.length < players.length) return null;
    return trick.determineWinner(trump);
  }

  // --- Scoring ---

  Map<int, int> calculateTeamScores() {
    final scores = <int, int>{};
    final biddingTeam = highestBidder?.teamId;

    for (var player in players) {
      scores[player.teamId] = (scores[player.teamId] ?? 0) + player.score;
    }

    if (trumpRevealed && trump != null && biddingTeam != null) {
      bool biddingTeamHeldK = false;
      bool biddingTeamHeldQ = false;

      for (final player in players) {
        if (player.teamId != biddingTeam) continue;
        for (final card in player.hand) {
          if (card.suit == trump) {
            if (card.rank == Rank.king) biddingTeamHeldK = true;
            if (card.rank == Rank.queen) biddingTeamHeldQ = true;
          }
        }
      }

      if (biddingTeamHeldK) scores[biddingTeam] = (scores[biddingTeam] ?? 0) + 4;
      if (biddingTeamHeldQ) scores[biddingTeam] = (scores[biddingTeam] ?? 0) + 4;

      for (final player in players) {
        if (player.teamId == biddingTeam) continue;
        for (final card in player.hand) {
          if (card.suit == trump) {
            if (card.rank == Rank.king) scores[player.teamId] = (scores[player.teamId] ?? 0) - 4;
            if (card.rank == Rank.queen) scores[player.teamId] = (scores[player.teamId] ?? 0) - 4;
          }
        }
      }
    }

    return scores;
  }

  void updateTeamScores() {
    teamScores = calculateTeamScores();
  }

  bool didBiddingTeamWin() {
    if (highestBidder == null) return false;
    updateTeamScores();
    final biddingTeam = highestBidder!.teamId;
    return (teamScores[biddingTeam] ?? 0) >= targetScore;
  }

  void printRoundSummary() {
    debugPrint('Round $roundNumber Summary');
    for (var player in players) {
      debugPrint('${player.name}: Tricks ${player.tricksWon}, Score ${player.score}');
    }
    debugPrint('Team Scores: $teamScores');
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
        .map((trickMap) => Trick.fromMap(Map<String, dynamic>.from(trickMap), allPlayers))
        .toList();

    final highestBidderId = (map['highestBidder'] as num?)?.toInt();
    final rawScores = Map<String, dynamic>.from(map['teamScores'] ?? {});
    final parsedScores = parseTeamScores(rawScores);

    return GameState(
      allPlayers,
      roundNumber: round,
      highestBidder: highestBidderId != null
          ? allPlayers.firstWhere((p) => p.id == highestBidderId, orElse: () => allPlayers.first)
          : null,
      trump: trumpSuit,
      trumpRevealed: map['trumpRevealed'] as bool? ?? false,
      currentTurn: (map['currentTurn'] as num?)?.toInt() ?? 0,
      targetScore: (map['targetScore'] as num?)?.toInt() ?? 29,
      tricksHistory: tricks,
      teamScores: parsedScores,
    );
  }

  void finalizeGame() {
    tricksHistory.clear();
  }

  bool isLegalMove(Card29 card) {
    return players.any((p) => p.hand.contains(card));
  }
}
