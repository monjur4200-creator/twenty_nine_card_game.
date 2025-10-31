import 'score_keeper.dart';

enum RoundModifier {
  none,
  double,
  redouble,
  fullSet,
  singleHand,
}

class GameManager {
  final ScoreKeeper keeper = ScoreKeeper();

  int bidderTeam = 1; // 1 or 2
  RoundModifier modifier = RoundModifier.none;
  bool bidderWonAllHands = false;
  bool roundStarted = false;

  // Current round log
  final List<String> history = [];

  // Persistent match log (list of rounds, each with its own log)
  final List<List<String>> matchHistory = [];

  void setBidder(int team) {
    bidderTeam = team;
    history.add("Team $team is the bidder");
  }

  void startRound() {
    roundStarted = true;
    history.add("Round started");
  }

  void endRound() {
    roundStarted = false;
    history.add("Round ended");
  }

  /// Opponent doubles the bid
  void applyDouble() {
    if (!roundStarted && modifier == RoundModifier.none) {
      modifier = RoundModifier.double;
      history.add("Opponent doubled");
    }
  }

  /// Bidder re‑doubles after a double
  void applyRedouble() {
    if (!roundStarted && modifier == RoundModifier.double) {
      modifier = RoundModifier.redouble;
      history.add("Bidder re‑doubled");
    }
  }

  /// Opponent escalates to full set after a re‑double
  void applyFullSet() {
    if (!roundStarted && modifier == RoundModifier.redouble) {
      modifier = RoundModifier.fullSet;
      history.add("Opponent escalated to Full Set");
    }
  }

  /// Single hand must be declared before play begins
  void applySingleHand() {
    if (!roundStarted && modifier == RoundModifier.none) {
      modifier = RoundModifier.singleHand;
      history.add("Single Hand declared");
    }
  }

  void setWonAllHands(bool wonAll) {
    bidderWonAllHands = wonAll;
  }

  /// Apply scoring rules at the end of a round
  void finalizeRound({required bool bidderWon}) {
    int basePoints = 0;

    // Default scoring
    if (bidderWon) {
      basePoints = bidderWonAllHands ? 2 : 1;
      history.add("Bidder team won the round");
      if (bidderWonAllHands) {
        history.add("Bidder team won all hands (+2)");
      }
    } else {
      basePoints = -1;
      history.add("Bidder team lost the round");
    }

    // Apply modifiers
    switch (modifier) {
      case RoundModifier.double:
        basePoints *= 2;
        history.add("Double applied → $basePoints points");
        break;
      case RoundModifier.redouble:
        basePoints *= 4;
        history.add("Re‑double applied → $basePoints points");
        break;
      case RoundModifier.fullSet:
        basePoints = bidderWon ? 6 : -6;
        history.add("Full Set applied → $basePoints points");
        break;
      case RoundModifier.singleHand:
        basePoints = bidderWon ? 3 : -3;
        history.add("Single Hand applied → $basePoints points");
        break;
      case RoundModifier.none:
        break;
    }

    // Apply to the correct team
    keeper.addPoints(bidderTeam, basePoints);
    history.add("Team $bidderTeam score updated by $basePoints");

    // Snapshot scores for this round
    keeper.snapshot();

    // Save this round’s history into the match log
    matchHistory.add(List<String>.from(history));

    // Reset round state
    modifier = RoundModifier.none;
    bidderWonAllHands = false;
    roundStarted = false;
    history.clear();
  }

  /// Reset everything for a new game (when returning to lobby)
  void resetGame() {
    keeper.reset();
    history.clear();
    matchHistory.clear();
    modifier = RoundModifier.none;
    bidderWonAllHands = false;
    roundStarted = false;
  }
}