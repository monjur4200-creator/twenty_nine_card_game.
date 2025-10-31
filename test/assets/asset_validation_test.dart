import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Asset Validation', () {
    test('All card asset filenames are lowercase and platform-safe', () {
      // Adjust this path if your assets are in a different folder
      final dir = Directory('assets/cards');

      expect(dir.existsSync(), true, reason: 'assets/cards directory not found');

      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .toList();

      expect(files.isNotEmpty, true, reason: 'No card assets found');

      for (final file in files) {
        // ✅ Check lowercase
        expect(file, file.toLowerCase(),
            reason: 'Filename "$file" is not lowercase');

        // ✅ Check platform-safe (no spaces, no uppercase, no special chars)
        final safePattern = RegExp(r'^[a-z0-9_\-]+\.(png|jpg|jpeg|svg)$');
        expect(safePattern.hasMatch(file), true,
            reason: 'Filename "$file" is not platform-safe');
      }
    });
  });
}
