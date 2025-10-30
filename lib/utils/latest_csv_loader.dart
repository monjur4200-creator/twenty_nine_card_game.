import 'dart:io';
import 'dart:async';

/// Finds the most recent CSV file in [directory] with [baseName] prefix.
Future<File?> findLatestCsv({
  String directory = 'test_results',
  String baseName = 'bot_stats_aggregate',
}) async {
  final dir = Directory(directory);
  if (!await dir.exists()) return null;

  final files = await dir
      .list()
      .where((f) => f is File && f.path.endsWith('.csv'))
      .cast<File>()
      .toList();

  if (files.isEmpty) return null;

  // Sort by modified time descending
  files.sort((a, b) =>
      b.lastModifiedSync().compareTo(a.lastModifiedSync()));

  // Return the most recent file that matches baseName
  return files.firstWhere(
    (f) => f.path.contains(baseName),
    orElse: () => files.first,
  );
}
