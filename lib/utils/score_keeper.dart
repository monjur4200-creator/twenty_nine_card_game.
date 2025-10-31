class TeamMarker {
  final String imagePath;
  const TeamMarker(this.imagePath);
}

class ScoreKeeper {
  int team1Score = 0;
  int team2Score = 0;

  // ✅ histories for match history widget
  final List<int> team1ScoreHistory = [];
  final List<int> team2ScoreHistory = [];

  // ✅ markers for scoreboard widgets
  final TeamMarker team1Marker = const TeamMarker('assets/images/team1_marker.png');
  final TeamMarker team2Marker = const TeamMarker('assets/images/team2_marker.png');

  void addPoints(int team, int points) {
    if (team == 1) {
      team1Score += points;
      team1ScoreHistory.add(team1Score);
    } else {
      team2Score += points;
      team2ScoreHistory.add(team2Score);
    }
  }

  /// ✅ snapshot method used by GameManager
  Map<String, dynamic> snapshot() {
    return {
      'team1': team1Score,
      'team2': team2Score,
      'team1History': List<int>.from(team1ScoreHistory),
      'team2History': List<int>.from(team2ScoreHistory),
    };
  }

  void reset() {
    team1Score = 0;
    team2Score = 0;
    team1ScoreHistory.clear();
    team2ScoreHistory.clear();
  }
}