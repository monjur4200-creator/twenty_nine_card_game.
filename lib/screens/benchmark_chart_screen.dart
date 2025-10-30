import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:twenty_nine_card_game/utils/benchmark_runner.dart';

class BenchmarkChartScreen extends StatelessWidget {
  final List<BenchmarkResult> results;

  const BenchmarkChartScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final exportSeries = charts.Series<BenchmarkResult, int>(
      id: 'Export',
      domainFn: (d, _) => d.runs,
      measureFn: (d, _) => d.exportMs,
      data: results,
      colorFn: (_, _) => charts.MaterialPalette.blue.shadeDefault,
    );

    final mergeSeries = charts.Series<BenchmarkResult, int>(
      id: 'Merge',
      domainFn: (d, _) => d.runs,
      measureFn: (d, _) => d.mergeMs,
      data: results,
      colorFn: (_, _) => charts.MaterialPalette.red.shadeDefault,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('CSV Benchmark Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: charts.LineChart(
          [exportSeries, mergeSeries],
          animate: true,
          behaviors: [
            charts.SeriesLegend(position: charts.BehaviorPosition.bottom),
            charts.ChartTitle('Number of Runs',
                behaviorPosition: charts.BehaviorPosition.bottom),
            charts.ChartTitle('Time (ms)',
                behaviorPosition: charts.BehaviorPosition.start),
          ],
        ),
      ),
    );
  }
}