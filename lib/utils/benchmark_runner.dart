import 'dart:async';

/// Holds the results of a benchmark run.
class BenchmarkResult {
  final int runs;
  final double exportMs;
  final double mergeMs;

  BenchmarkResult({
    required this.runs,
    required this.exportMs,
    required this.mergeMs,
  });

  @override
  String toString() =>
      'BenchmarkResult(runs: $runs, export: ${exportMs.toStringAsFixed(2)} ms, '
      'merge: ${mergeMs.toStringAsFixed(2)} ms)';
}

/// Utility to measure elapsed time of an async function.
Future<double> _timeAsync(Future<void> Function() action) async {
  final sw = Stopwatch()..start();
  await action();
  sw.stop();
  return sw.elapsedMilliseconds.toDouble();
}

/// Run a benchmark for export + merge operations.
/// [exportAction] and [mergeAction] are async functions you pass in
/// (e.g., wrappers around your CSV utils).
Future<BenchmarkResult> runBenchmark({
  required int runs,
  required Future<void> Function() exportAction,
  required Future<void> Function() mergeAction,
}) async {
  final exportMs = await _timeAsync(exportAction);
  final mergeMs = await _timeAsync(mergeAction);

  return BenchmarkResult(
    runs: runs,
    exportMs: exportMs,
    mergeMs: mergeMs,
  );
}
