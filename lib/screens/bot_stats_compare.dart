import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:twenty_nine_card_game/utils/csv_utils.dart';

class BotComparisonData {
  final String bot;
  final double run1Percent;
  final double run2Percent;
  final double delta; // run2 - run1

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

    final series = <charts.Series<BotComparisonData, String>>[
      charts.Series<BotComparisonData, String>(
        id: 'Run 1',
        domainFn: (d, _) => d.bot,
        measureFn: (d, _) => d.run1Percent,
        data: data,
        colorFn: (d, i) => charts.MaterialPalette.blue.shadeDefault,
        labelAccessorFn: (d, _) => '${d.run1Percent.toStringAsFixed(1)}%',
      ),
      charts.Series<BotComparisonData, String>(
        id: 'Run 2',
        domainFn: (d, _) => d.bot,
        measureFn: (d, _) => d.run2Percent,
        data: data,
        colorFn: (d, i) => charts.MaterialPalette.red.shadeDefault,
        labelAccessorFn: (d, _) {
          final sign = d.delta >= 0 ? '+' : '';
          return '${d.run2Percent.toStringAsFixed(1)}% ($sign${d.delta.toStringAsFixed(1)})';
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Compare Two Runs (with Δ)')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: charts.BarChart(
                series,
                animate: true,
                barGroupingType: charts.BarGroupingType.grouped,
                vertical: true,
                barRendererDecorator: charts.BarLabelDecorator<String>(),
                domainAxis: const charts.OrdinalAxisSpec(),
                primaryMeasureAxis: charts.PercentAxisSpec(),
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
                  final deltaColor =
                      d.delta > 0 ? Colors.green : (d.delta < 0 ? Colors.red : Colors.grey);

                  return DataRow(
                    cells: [
                      DataCell(Text(d.bot)),
                      DataCell(Text('${d.run1Percent.toStringAsFixed(1)}%')),
                      DataCell(Text('${d.run2Percent.toStringAsFixed(1)}%')),
                      DataCell(
                        Text(
                          deltaStr,
                          style: TextStyle(
                            color: deltaColor,
                            fontWeight: FontWeight.bold,
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
}