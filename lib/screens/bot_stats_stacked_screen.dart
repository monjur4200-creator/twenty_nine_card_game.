import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BotShareData {
  final int runIndex;
  final String bot;
  final double percent;

  BotShareData(this.runIndex, this.bot, this.percent);
}

class BotStatsStackedScreen extends StatelessWidget {
  final List<Map<String, double>> normalizedRuns;

  const BotStatsStackedScreen({
    super.key,
    required this.normalizedRuns,
  });

  @override
  Widget build(BuildContext context) {
    final bots = normalizedRuns.first.keys.toList();
    final runLabels = List.generate(normalizedRuns.length, (i) => 'Run ${i + 1}');
    final barGroups = _buildStackedGroups(bots, normalizedRuns);

    return Scaffold(
      appBar: AppBar(title: const Text('Bot Win Shares (Stacked)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= runLabels.length) return const SizedBox.shrink();
                    return Text(runLabels[index], style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildStackedGroups(
    List<String> bots,
    List<Map<String, double>> normalizedRuns,
  ) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
    ];

    return List.generate(normalizedRuns.length, (runIndex) {
      final botPercents = normalizedRuns[runIndex];
      double runningTotal = 0;

      final rods = <BarChartRodStackItem>[];
      for (int i = 0; i < bots.length; i++) {
        final bot = bots[i];
        final percent = botPercents[bot] ?? 0.0;
        final start = runningTotal;
        final end = start + percent;
        rods.add(
          BarChartRodStackItem(start, end, colors[i % colors.length]),
        );
        runningTotal = end;
      }

      return BarChartGroupData(
        x: runIndex,
        barRods: [
          BarChartRodData(
            toY: 100,
            rodStackItems: rods,
            width: 20,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });
  }
}