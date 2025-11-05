import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:twenty_nine_card_game/utils/csv_utils.dart';

class BotComparisonData {
  final String bot;
  final double run1Percent;
  final double run2Percent;
  final double delta;

  BotComparisonData(this.bot, this.run1Percent, this.run2Percent)
      : delta = run2Percent - run1Percent;
}

class BotStatsCompareScreen extends StatelessWidget {
  final Map<String, int> run1;
  final Map<String, int> run2;

  const BotStatsCompareScreen({
    super.key,
    required this.run1,
    required this.run2,
  });

  @override
  Widget build(BuildContext context) {
    final norm1 = normalizeWinCounts(run1);
    final norm2 = normalizeWinCounts(run2);

    final bots = {...norm1.keys, ...norm2.keys};
    final data = bots.map((bot) {
      return BotComparisonData(
        bot,
        norm1[bot] ?? 0.0,
        norm2[bot] ?? 0.0,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Compare Two Runs (with Δ)')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
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
                          return Text(data[index].bot, style: const TextStyle(fontSize: 10));
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
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Bot')),
                  DataColumn(label: Text('Run 1 %')),
                  DataColumn(label: Text('Run 2 %')),
                  DataColumn(label: Text('Δ')),
                ],
                rows: data.map((d) {
                  final sign = d.delta >= 0 ? '+' : '';
                  final deltaStr = '$sign${d.delta.toStringAsFixed(1)}%';

                  return DataRow(
                    cells: [
                      DataCell(Text(d.bot)),
                      DataCell(Text('${d.run1Percent.toStringAsFixed(1)}%')),
                      DataCell(Text('${d.run2Percent.toStringAsFixed(1)}%')),
                      DataCell(
                        Text(
                          deltaStr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<BotComparisonData> data) {
    return List.generate(data.length, (i) {
      final d = data[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: d.run1Percent,
            color: Colors.blue,
            width: 8,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: d.run2Percent,
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