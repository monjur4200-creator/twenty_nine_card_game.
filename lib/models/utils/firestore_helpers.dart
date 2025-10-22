/// Utility to parse Firestore teamScores (string keys) back into int keys.
Map<int, int> parseTeamScores(Map<String, dynamic> raw) {
  return raw.map((k, v) => MapEntry(int.parse(k), v as int));
}

/// Utility to convert int-keyed teamScores into string keys for Firestore.
Map<String, int> teamScoresToFirestore(Map<int, int> scores) {
  return scores.map((k, v) => MapEntry(k.toString(), v));
}
