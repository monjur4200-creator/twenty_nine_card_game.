import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Simple data model for chart
class BotWinData {
  final String name;
  final int wins;

  BotWinData(this.name, this.wins);
}

class BotStatsScreen extends StatelessWidget {
  final Map<String, int> winCounts;

  const BotStatsScreen({
    super.key,
    required this.winCounts,
  });

  @override
  Widget build(BuildContext context) {
    final data = winCounts.entries
        .map((entry) => BotWinData(entry.key, entry.value))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bot Win Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            barGroups: _buildBarGroups(data),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) return const SizedBox.shrink();
                    return Text(data[index].name, style: const TextStyle(fontSize: 10));
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

  List<BarChartGroupData> _buildBarGroups(List<BotWinData> data) {
    return List.generate(data.length, (i) {
      final d = data[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: d.wins.toDouble(),
            color: Colors.blue,
            width: 12,
            borderRadius: BorderRadius.zero,
          ),
        ],
        barsSpace: 4,
      );
    });
  }
}