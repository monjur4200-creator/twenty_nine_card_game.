import 'dart:io';
import 'package:csv/csv.dart';

/// Normalize raw win counts into percentages (0–100).
Map<String, double> normalizeWinCounts(Map<String, int> counts) {
  final total = counts.values.fold<int>(0, (a, b) => a + b);
  if (total == 0) {
    return {for (var k in counts.keys) k: 0.0};
  }
  return {
    for (var e in counts.entries) e.key: (e.value / total) * 100.0,
  };
}

/// Export a list of win-count maps to a CSV file.
/// Each row = one run, each column = bot name.
Future<void> exportWinCountsToCsv(
    String filePath, List<Map<String, int>> runs) async {
  if (runs.isEmpty) return;

  // Collect all bot names
  final allBots = <String>{};
  for (final run in runs) {
    allBots.addAll(run.keys);
  }
  final botList = allBots.toList()..sort();

  // Build CSV rows
  final rows = <List<dynamic>>[];
  rows.add(['Run', ...botList]); // header row
  for (int i = 0; i < runs.length; i++) {
    final run = runs[i];
    rows.add([
      i + 1,
      ...botList.map((b) => run[b] ?? 0),
    ]);
  }

  final csv = const ListToCsvConverter().convert(rows);
  final file = File(filePath);
  await file.writeAsString(csv);
}

/// Merge multiple CSV files into one.
/// Assumes all files have the same header row.
Future<void> mergeCsvFiles(List<String> inputPaths, String outputPath) async {
  if (inputPaths.isEmpty) return;

  final mergedRows = <List<dynamic>>[];
  for (int i = 0; i < inputPaths.length; i++) {
    final file = File(inputPaths[i]);
    if (!file.existsSync()) continue;

    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);

    if (i == 0) {
      mergedRows.addAll(rows); // include header
    } else {
      mergedRows.addAll(rows.skip(1)); // skip header
    }
  }

  final csv = const ListToCsvConverter().convert(mergedRows);
  final outFile = File(outputPath);
  await outFile.writeAsString(csv);
}

/// Merge the latest N CSV files (by modified time).
Future<void> mergeLatestNFiles(
    int n, String directoryPath, String outputPath) async {
  final dir = Directory(directoryPath);
  if (!dir.existsSync()) return;

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.csv'))
      .toList();

  files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
  final latest = files.take(n).map((f) => f.path).toList();

  await mergeCsvFiles(latest, outputPath);
}

/// Merge all CSV files in a directory.
Future<void> mergeAllFiles(String directoryPath, String outputPath) async {
  final dir = Directory(directoryPath);
  if (!dir.existsSync()) return;

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.csv'))
      .map((f) => f.path)
      .toList();

  await mergeCsvFiles(files, outputPath);
}
