import 'dart:math';
import 'package:flutter/foundation.dart';

/// Calculates the Meta Health Index (MHI) for a set of normalized runs.
///
/// Each run is a map of botName → win percentage (0–100).
/// The MHI blends three factors:
///   1. Volatility (crown changes across runs)
///   2. Fairness (dominance vs equal share, with multi-bot skew guard and non-linear penalty)
///   3. Stability (consistency of the top bot across runs)
///
/// Returns a score between 0 and 100.
double calculateMetaHealthIndex({
  required List<Map<String, double>> normalizedRuns,
}) {
  if (normalizedRuns.isEmpty) return 0.0;

  // --- 1. Volatility ---
  final topBots = <String>[];
  for (final run in normalizedRuns) {
    if (run.isEmpty) continue;
    final topBot = run.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    ).key;
    topBots.add(topBot);
  }

  int crownChanges = 0;
  for (int i = 1; i < topBots.length; i++) {
    if (topBots[i] != topBots[i - 1]) crownChanges++;
  }

  final volatilityPercent = topBots.length > 1
      ? (crownChanges / (topBots.length - 1)) * 100
      : 0.0;
  final double vScore = (100 - volatilityPercent).clamp(0.0, 100.0);

  // --- 2. Fairness ---
  final allBots = normalizedRuns.expand((r) => r.keys).toSet();
  if (allBots.isEmpty) return 0.0;

  final avgShares = {
    for (var bot in allBots)
      bot: normalizedRuns
              .map((r) => r[bot] ?? 0.0)
              .reduce((a, b) => a + b) /
          normalizedRuns.length
  };

  final n = avgShares.length;
  final maxShare = avgShares.values.reduce(max) / 100.0;
  final minShare = avgShares.values.reduce(min) / 100.0;
  final spread = (maxShare - minShare);
  final idealShare = 1.0 / n;

  final imbalance = (maxShare - idealShare).clamp(0.0, 1.0);
  final worstCaseImbalance = (1.0 - idealShare);
  double fairnessRatio =
      worstCaseImbalance == 0 ? 0.0 : (imbalance / worstCaseImbalance);

  double fScore = pow(1 - fairnessRatio, 4) * 100;

  if (maxShare >= 0.80 || minShare <= 0.20) {
    fScore = min(fScore, 35); // Unhealthy
  } else if (maxShare >= 0.60 || minShare <= 0.40) {
    fScore = min(fScore, 55); // Watchlist
  }

  if (spread > 0.50) {
    fScore = min(fScore, 30);
  } else if (spread > 0.30) {
    fScore = min(fScore, 50);
  }

  if (n >= 3 && (avgShares.values.reduce(max) - avgShares.values.reduce(min)) <= 10.0) {
    fScore = max(fScore, 75); // Balanced cluster → Healthy
  }

  // --- 3. Stability ---
  final counts = <String, int>{};
  for (final bot in topBots) {
    counts[bot] = (counts[bot] ?? 0) + 1;
  }
  final maxCount = counts.values.isEmpty ? 0 : counts.values.reduce(max);
  final double sScore =
      topBots.isEmpty ? 0.0 : (maxCount / topBots.length) * 100;

  double mhi =
      (0.30 * vScore + 0.50 * fScore + 0.20 * sScore).clamp(0.0, 100.0);

  // --- Dominance override (true 100–0 metas) ---
  const double dominanceEps = 0.001;
  final bool isTrueDominance =
      sScore == 100.0 && vScore == 100.0 && maxShare >= (1.0 - dominanceEps);

  if (isTrueDominance) {
    mhi = (mhi + 40.0).clamp(0.0, 100.0);
  }

  return mhi;
}

/// Classification result for Meta Health Index.
class MetaHealthClassification {
  final String label;
  final String color; // 'green', 'orange', 'red'

  const MetaHealthClassification(this.label, this.color);
}

/// Returns a label + color band with rule-based overrides.
MetaHealthClassification classifyMetaHealth(
  double mhi, {
  required List<Map<String, double>> normalizedRuns,
}) {
  if (normalizedRuns.isEmpty) {
    return const MetaHealthClassification('Unhealthy', 'red');
  }

  final allBots = normalizedRuns.expand((r) => r.keys).toSet();
  final avgShares = {
    for (var bot in allBots)
      bot: normalizedRuns.map((r) => r[bot] ?? 0.0).reduce((a, b) => a + b) /
          normalizedRuns.length
  };
  final n = avgShares.length;
  final maxSharePct = avgShares.values.reduce(max);
  final minSharePct = avgShares.values.reduce(min);
  final maxShare = maxSharePct / 100.0;
  final minShare = minSharePct / 100.0;
  final spread = maxShare - minShare;

  // --- Rule overrides ---
  // 1) True dominance (100–0 every run) → Healthy
  final allRunsSameWinner = normalizedRuns.every((r) {
    final top = r.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.value >= 99.9;
  });
  if (allRunsSameWinner) {
    return const MetaHealthClassification('Healthy Meta', 'green');
  }

  // 2) Balanced multi-way cluster → Healthy (checked early!)
  if (n >= 3 && (maxSharePct - minSharePct) <= 10.0) {
    return const MetaHealthClassification('Healthy Meta', 'green');
  }

  // 3) Extreme skew → Unhealthy (≥80% or ≤20%)
  if (maxShare >= 0.80 || minShare <= 0.20) {
    return const MetaHealthClassification('Unhealthy', 'red');
  }
  if (spread > 0.50) {
    return const MetaHealthClassification('Unhealthy', 'red');
  }

  // 4) Borderline fairness (≥60–40) → Watchlist
  if (maxShare >= 0.60 || minShare <= 0.40) {
    return const MetaHealthClassification('Watchlist', 'orange');
  }
  if (spread > 0.30) {
    return const MetaHealthClassification('Watchlist', 'orange');
  }

  // --- Fallback to MHI bands ---
  if (mhi >= 62) {
    return const MetaHealthClassification('Healthy Meta', 'green');
  } else if (mhi >= 45) {
    return const MetaHealthClassification('Watchlist', 'orange');
  } else {
    return const MetaHealthClassification('Unhealthy', 'red');
  }
}

/// Debug helper: prints component scores, rule triggers, and final MHI.
void debugExplainMetaHealth(List<Map<String, double>> runs) {
  final mhi = calculateMetaHealthIndex(normalizedRuns: runs);

  final topBots = <String>[];
  for (final run in runs) {
    if (run.isEmpty) continue;
    final topBot = run.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    ).key;
    topBots.add(topBot);
  }

  int crownChanges = 0;
  for (int i = 1; i < topBots.length; i++) {
    if (topBots[i] != topBots[i - 1]) crownChanges++;
  }
  final volatilityPercent = topBots.length > 1
      ? (crownChanges / (topBots.length - 1)) * 100
      : 0.0;
  final vScore = (100 - volatilityPercent).clamp(0.0, 100.0);

  final allBots = runs.expand((r) => r.keys).toSet();
  final avgShares = {
    for (var bot in allBots)
      bot: runs.map((r) => r[bot] ?? 0.0).reduce((a, b) => a + b) / runs.length
  };
  final n = avgShares.length;
  final maxSharePct = avgShares.values.reduce(max);
  final minSharePct = avgShares.values.reduce(min);
  final spread = (maxSharePct - minSharePct);

    // Rule trigger explanation
  String rule = 'Bands';
  final allRunsSameWinner = runs.every((r) {
    final top = r.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.value >= 99.9;
  });
  if (allRunsSameWinner) {
    rule = 'Rule: true dominance (100–0) → Healthy';
  } else if (n >= 3 && (maxSharePct - minSharePct) <= 10.0) {
    rule = 'Rule: 3-way cluster (≤10% spread) → Healthy';
  } else if (maxSharePct / 100.0 >= 0.80 || minSharePct / 100.0 <= 0.20) {
    rule = 'Rule: extreme skew (≥80% or ≤20%) → Unhealthy';
  } else if (spread > 50.0) {
    rule = 'Rule: spread > 50% → Unhealthy';
  } else if (maxSharePct / 100.0 >= 0.60 || minSharePct / 100.0 <= 0.40) {
    rule = 'Rule: borderline fairness (≥60–40) → Watchlist';
  } else if (spread > 30.0) {
    rule = 'Rule: spread > 30% → Watchlist';
  }

  final classification = classifyMetaHealth(mhi, normalizedRuns: runs);

  debugPrint('--- Meta Health Debug ---');
  debugPrint('Volatility Score: ${vScore.toStringAsFixed(2)}');
  debugPrint(
      'Max/Min Shares:   ${maxSharePct.toStringAsFixed(1)} / ${minSharePct.toStringAsFixed(1)}');
  debugPrint('Spread:           ${(spread).toStringAsFixed(2)}%');
  debugPrint('Rule Applied:     $rule');
  debugPrint('Final MHI:        ${mhi.toStringAsFixed(4)}');
  debugPrint('Classification:   ${classification.label}');
  debugPrint('-------------------------');
}
