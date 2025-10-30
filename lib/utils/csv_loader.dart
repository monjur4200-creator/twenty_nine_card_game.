import 'dart:io';
import 'package:csv/csv.dart';

Future<List<Map<String, int>>> loadCsvFiles(List<String> paths) async {
  final results = <Map<String, int>>[];
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final content = await file.readAsString();
    final rows = CsvToListConverter().convert(content);
    if (rows.isEmpty) continue;

    final headers = rows.first.cast<String>();
    for (final row in rows.skip(1)) {
      final map = <String, int>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] =
            row[i] is int ? row[i] : int.tryParse(row[i].toString()) ?? 0;
      }
      results.add(map);
    }
  }
  return results;
}
