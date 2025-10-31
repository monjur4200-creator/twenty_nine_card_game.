import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/utils/meta_health.dart';

void main() {
  group('Meta Health Index', () {
    test('returns 0.0 for empty runs', () {
      final mhi = calculateMetaHealthIndex(normalizedRuns: []);
      expect(mhi, equals(0.0));
    });

    test('stable meta with one dominant bot → Healthy (override)', () {
      final runs = [
        {'AggroBot': 100.0, 'CarefulBot': 0.0},
        {'AggroBot': 100.0, 'CarefulBot': 0.0},
        {'AggroBot': 100.0, 'CarefulBot': 0.0},
      ];
      final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
      final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

      expect(classification.label, equals('Healthy Meta'));
      expect(classification.color, equals('green'));
    });

    test('volatile meta with crown changes → Watchlist/Unhealthy', () {
      final runs = [
        {'AggroBot': 60.0, 'CarefulBot': 40.0},
        {'AggroBot': 40.0, 'CarefulBot': 60.0},
        {'AggroBot': 55.0, 'CarefulBot': 45.0},
        {'AggroBot': 45.0, 'CarefulBot': 55.0},
      ];
      final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
      final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

      expect(classification.label, isNot(equals('Healthy Meta')));
    });

    test('unfair meta with skewed win shares → Unhealthy', () {
      final runs = [
        {'AggroBot': 90.0, 'CarefulBot': 10.0},
        {'AggroBot': 85.0, 'CarefulBot': 15.0},
        {'AggroBot': 95.0, 'CarefulBot': 5.0},
      ];
      final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
      final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

      expect(classification.label, equals('Unhealthy'));
      expect(classification.color, equals('red'));
    });

    test('balanced meta with fair shares → Healthy', () {
      final runs = [
        {'AggroBot': 50.0, 'CarefulBot': 50.0},
        {'AggroBot': 52.0, 'CarefulBot': 48.0},
        {'AggroBot': 49.0, 'CarefulBot': 51.0},
      ];
      final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
      final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

      expect(classification.label, equals('Healthy Meta'));
      expect(classification.color, equals('green'));
    });

    test('borderline fairness: 70–30 split → Watchlist', () {
      final runs = [
        {'AggroBot': 70.0, 'CarefulBot': 30.0},
        {'AggroBot': 72.0, 'CarefulBot': 28.0},
        {'AggroBot': 68.0, 'CarefulBot': 32.0},
      ];
      final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
      final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

      expect(classification.label, equals('Watchlist'));
      expect(classification.color, equals('orange'));
    });

    test('borderline fairness: 60–40 split → Watchlist', () {
      final runs = [
        {'AggroBot': 60.0, 'CarefulBot': 40.0},
        {'AggroBot': 62.0, 'CarefulBot': 38.0},
        {'AggroBot': 58.0, 'CarefulBot': 42.0},
      ];
      final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
      final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

      expect(classification.label, equals('Watchlist'));
      expect(classification.color, equals('orange'));
    });

    test('cyclical dominance with crown swaps → not Healthy', () {
      final runs = [
        {'AggroBot': 60.0, 'CarefulBot': 40.0},
        {'AggroBot': 40.0, 'CarefulBot': 60.0},
        {'AggroBot': 55.0, 'CarefulBot': 45.0},
        {'AggroBot': 45.0, 'CarefulBot': 55.0},
      ];
      final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
      final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

      expect(classification.label, isNot(equals('Healthy Meta')));
    });

    test('three-way balanced meta → Healthy', () {
      final runs = [
        {'AggroBot': 34.0, 'CarefulBot': 33.0, 'LogicBot': 33.0},
        {'AggroBot': 33.0, 'CarefulBot': 34.0, 'LogicBot': 33.0},
        {'AggroBot': 33.0, 'CarefulBot': 33.0, 'LogicBot': 34.0},
      ];
      final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
      final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

      expect(classification.label, equals('Healthy Meta'));
      expect(classification.color, equals('green'));
    });

    test('four-bot skewed meta (70–10–10–10) → Unhealthy', () {
      final runs = [
        {'AggroBot': 70.0, 'CarefulBot': 10.0, 'LogicBot1': 10.0, 'LogicBot2': 10.0},
        {'AggroBot': 72.0, 'CarefulBot': 8.0,  'LogicBot1': 10.0, 'LogicBot2': 10.0},
        {'AggroBot': 68.0, 'CarefulBot': 12.0, 'LogicBot1': 10.0, 'LogicBot2': 10.0},
      ];
      final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
      final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

      expect(classification.label, equals('Unhealthy'));
      expect(classification.color, equals('red'));
    });

    test('randomized multi-bot fuzz test → MHI stays valid', () {
      final rng = Random(42); // fixed seed for reproducibility

      for (int i = 0; i < 100; i++) {
        final botCount = 4 + rng.nextInt(2); // 4 or 5 bots
        final raw = List<double>.generate(botCount, (_) => rng.nextDouble());
        final sum = raw.reduce((a, b) => a + b);
        final normalized = raw.map((v) => (v / sum) * 100).toList();

        final run = {
          for (int j = 0; j < botCount; j++) 'Bot$j': normalized[j],
        };

        final runs = List.generate(3, (_) => Map<String, double>.from(run));

        final mhi = calculateMetaHealthIndex(normalizedRuns: runs);
        final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

        expect(mhi >= 0.0 && mhi <= 100.0, isTrue,
            reason: 'MHI out of bounds: $mhi');
        expect(
          ['Healthy Meta', 'Watchlist', 'Unhealthy'],
          contains(classification.label),
          reason: 'Invalid classification: ${classification.label}',
        );
      }
    });
  });
}
