import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:twenty_nine_card_game/utils/benchmark_runner.dart';

class BenchmarkChartScreen extends StatelessWidget {
  final List<BenchmarkResult> results;

  const BenchmarkChartScreen({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Benchmark Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            barGroups: _buildBarGroups(),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= results.length) return const SizedBox.shrink();
                    return Text('Run ${results[index].runs}');
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: true),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(results.length, (i) {
      final result = results[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: result.exportMs.toDouble(),
            color: Colors.blue,
            width: 8,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: result.mergeMs.toDouble(),
            color: Colors.red,
            width: 8,
            borderRadius: BorderRadius.zero,
          ),
        ],
        barsSpace: 4,
      );
    });
  }
}