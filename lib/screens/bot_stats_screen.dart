import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
    required this.winCounts, // ✅ required parameter to initialize the field
  });

  @override
  Widget build(BuildContext context) {
    final data = winCounts.entries
        .map((e) => BotWinData(e.key, e.value))
        .toList();

    final series = [
      charts.Series<BotWinData, String>(
        id: 'BotWins',
        colorFn: (_, _) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (d, _) => d.name,
        measureFn: (d, _) => d.wins,
        data: data,
        labelAccessorFn: (d, _) => '${d.wins}',
      )
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Bot Win Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: charts.BarChart(
          series,
          animate: true,
          vertical: true,
          barRendererDecorator: charts.BarLabelDecorator<String>(),
          domainAxis: const charts.OrdinalAxisSpec(),
        ),
      ),
    );
  }
}