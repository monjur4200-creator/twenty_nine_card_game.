import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BotTrendData {
  final int runIndex;
  final String bot;
  final int wins;

  BotTrendData(this.runIndex, this.bot, this.wins);
}

class BotStatsTrendScreen extends StatelessWidget {
  final List<Map<String, int>> runs;

  const BotStatsTrendScreen({
    super.key,
    required this.runs,
  });

  @override
  Widget build(BuildContext context) {
    final data = <BotTrendData>[];

    for (int i = 0; i < runs.length; i++) {
      runs[i].forEach((bot, wins) {
        data.add(BotTrendData(i + 1, bot, wins));
      });
    }

    final bots = runs.first.keys.toList();
    final lines = _buildLineChartData(bots, data);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bot Win Trends'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            lineBarsData: lines,
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text('Run ${value.toInt()}');
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineTouchData: const LineTouchData(enabled: true),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineChartData(
    List<String> bots,
    List<BotTrendData> data,
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

    return List.generate(bots.length, (i) {
      final bot = bots[i];
      final botData = data.where((d) => d.bot == bot).toList();

      return LineChartBarData(
        spots: botData
            .map((d) => FlSpot(d.runIndex.toDouble(), d.wins.toDouble()))
            .toList(),
        isCurved: true,
        barWidth: 3,
        color: colors[i % colors.length],
        dotData: const FlDotData(show: true),
      );
    });
  }
}