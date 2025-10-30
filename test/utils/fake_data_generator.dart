import 'dart:math';

/// Generate fake bot win counts for testing.
/// [botNames] = list of bot identifiers
/// [games] = total number of games to distribute
/// Returns a map: {BotName: Wins}
Map<String, int> generateFakeWinCounts(
  List<String> botNames, {
  int games = 100,
  int seed = 42,
}) {
  final rng = Random(seed);
  final counts = {for (final bot in botNames) bot: 0};

  for (int i = 0; i < games; i++) {
    final winner = botNames[rng.nextInt(botNames.length)];
    counts[winner] = counts[winner]! + 1;
  }

  return counts;
}

/// Generate multiple runs of fake win counts.
/// Returns a list of maps, one per run.
List<Map<String, int>> generateMultipleRuns(
  List<String> botNames, {
  int runs = 5,
  int gamesPerRun = 100,
  int seed = 42,
}) {
  final results = <Map<String, int>>[];
  for (int i = 0; i < runs; i++) {
    results.add(generateFakeWinCounts(
      botNames,
      games: gamesPerRun,
      seed: seed + i, // vary seed per run
    ));
  }
  return results;
}
