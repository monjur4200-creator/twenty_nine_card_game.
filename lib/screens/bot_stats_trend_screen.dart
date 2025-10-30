import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
    required this.runs, // ✅ required parameter to initialize the field
  });

  @override
  Widget build(BuildContext context) {
    final data = <BotTrendData>[];

    for (int i = 0; i < runs.length; i++) {
      runs[i].forEach((bot, wins) {
        data.add(BotTrendData(i + 1, bot, wins));
      });
    }

    final series = <charts.Series<BotTrendData, int>>[];

    final bots = runs.first.keys;
    for (final bot in bots) {
      series.add(
        charts.Series<BotTrendData, int>(
          id: bot,
          colorFn: (_, _) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (d, _) => d.runIndex,
          measureFn: (d, _) => d.wins,
          data: data.where((d) => d.bot == bot).toList(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bot Win Trends')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: charts.LineChart(
          series,
          animate: true,
          primaryMeasureAxis: const charts.NumericAxisSpec(),
          domainAxis: const charts.NumericAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(),
          ),
        ),
      ),
    );
  }
}