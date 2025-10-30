import 'package:flutter/foundation.dart'; // for debugPrint
import 'dart:io';

/// Aggregates multiple CSV files of bot win counts into a combined dataset.
/// Each row in the output: RunIndex,BotName,Wins,Percent
Future<String> aggregateCsvFiles(
  List<String> filePaths, {
  String directory = 'test_results',
  String baseName = 'bot_stats_aggregate',
}) async {
  final buffer = StringBuffer();
  buffer.writeln('RunIndex,BotName,Wins,Percent');

  for (int i = 0; i < filePaths.length; i++) {
    final file = File(filePaths[i]);
    if (!await file.exists()) continue;

    final lines = await file.readAsLines();
    // Skip header row
    for (var j = 1; j < lines.length; j++) {
      if (lines[j].trim().isEmpty) continue;
      buffer.writeln('${i + 1},${lines[j]}');
    }
  }

  // Ensure output directory exists
  final dir = Directory(directory);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final filePath = '$directory/$baseName.csv';
  final outFile = File(filePath);
  await outFile.writeAsString(buffer.toString());

  // ignore: avoid_print
  debugPrint('✅ Aggregated CSV written to $filePath');
  return filePath;
}
