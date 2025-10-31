import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/utils/meta_health.dart';

void main() {
  group('Meta Health Index Fuzz Tests', () {
    final rng = Random();

    test('MHI stays within [0,100] and classification is valid', () {
      for (int i = 0; i < 100; i++) {
        // Generate between 2 and 5 bots
        final botCount = 2 + rng.nextInt(4);
        final botNames = List.generate(botCount, (j) => 'Bot$j');

        // Generate between 3 and 10 runs
        final runCount = 3 + rng.nextInt(8);
        final runs = <Map<String, double>>[];

        for (int r = 0; r < runCount; r++) {
          final scores = <String, double>{};
          double remaining = 100.0;

          // Assign random percentages that sum to ~100
          for (int b = 0; b < botCount; b++) {
            if (b == botCount - 1) {
              scores[botNames[b]] = remaining;
            } else {
              final share = rng.nextDouble() * remaining;
              scores[botNames[b]] = share;
              remaining -= share;
            }
          }
          runs.add(scores);
        }

        final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
        final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

        // Invariants
        expect(mhi, inInclusiveRange(0.0, 100.0));
        expect(
          ['Healthy Meta', 'Watchlist', 'Unhealthy'],
          contains(classification.label),
        );

        // Optional: debug print for the first few runs
        if (i < 3) {
          debugExplainMetaHealth(runs);
        }
      }
    });
  });
}
