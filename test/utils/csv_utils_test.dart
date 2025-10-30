import 'dart:io';
import 'package:test/test.dart';
import 'package:twenty_nine_card_game/utils/csv_utils.dart';

void main() {
  group('CSV Utils', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('csv_utils_test');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('normalizeWinCounts returns correct percentages', () {
      final counts = {'AggroBot': 2, 'CarefulBot': 3};
      final normalized = normalizeWinCounts(counts);

      expect(normalized['AggroBot']!.toStringAsFixed(1), '40.0');
      expect(normalized['CarefulBot']!.toStringAsFixed(1), '60.0');
    });

    test('exportWinCountsToCsv creates file with header and rows', () async {
      final runs = [
        {'AggroBot': 5, 'CarefulBot': 5}
      ];
      final filePath = '${tempDir.path}/test_export.csv';

      await exportWinCountsToCsv(filePath, runs);

      final file = File(filePath);
      expect(await file.exists(), isTrue);
      final lines = await file.readAsLines();
      expect(lines.first, contains('Run')); // header row
      expect(lines.length, 2); // header + 1 run
    });

    test('mergeCsvFiles merges multiple files', () async {
      final file1 = '${tempDir.path}/merge1.csv';
      final file2 = '${tempDir.path}/merge2.csv';
      final output = '${tempDir.path}/merged.csv';

      await exportWinCountsToCsv(file1, [
        {'AggroBot': 2, 'CarefulBot': 8}
      ]);
      await exportWinCountsToCsv(file2, [
        {'AggroBot': 6, 'CarefulBot': 4}
      ]);

      await mergeCsvFiles([file1, file2], output);

      final merged = File(output);
      final lines = await merged.readAsLines();
      expect(lines.first, contains('Run')); // header row
      expect(lines.length, greaterThan(2));
    });

    test('mergeLatestNFiles merges the latest N files', () async {
      final counts = {'AggroBot': 1, 'CarefulBot': 9};
      for (int i = 0; i < 3; i++) {
        final filePath = '${tempDir.path}/latest_$i.csv';
        await exportWinCountsToCsv(filePath, [counts]);
        await Future.delayed(Duration(milliseconds: 10));
      }

      final output = '${tempDir.path}/latestN.csv';
      await mergeLatestNFiles(2, tempDir.path, output);

      final merged = File(output);
      final lines = await merged.readAsLines();
      expect(lines.first, contains('Run'));
      expect(lines.length, greaterThan(2));
    });

    test('mergeAllFiles merges all CSVs in directory', () async {
      final counts = {'AggroBot': 5, 'CarefulBot': 5};
      for (int i = 0; i < 3; i++) {
        final filePath = '${tempDir.path}/all_$i.csv';
        await exportWinCountsToCsv(filePath, [counts]);
      }

      final output = '${tempDir.path}/all_runs.csv';
      await mergeAllFiles(tempDir.path, output);

      final merged = File(output);
      final lines = await merged.readAsLines();
      expect(lines.first, contains('Run'));
      expect(lines.length, greaterThan(3));
    });
  });
}
