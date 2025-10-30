import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
    required this.normalizedRuns, // ✅ required parameter to initialize the field
  });

  @override
  Widget build(BuildContext context) {
    final series = <charts.Series<BotShareData, String>>[];

    // Collect all bot names
    final bots = normalizedRuns.first.keys;

    for (final bot in bots) {
      final data = <BotShareData>[];
      for (int i = 0; i < normalizedRuns.length; i++) {
        final percent = normalizedRuns[i][bot] ?? 0.0;
        data.add(BotShareData(i + 1, bot, percent));
      }

      series.add(
        charts.Series<BotShareData, String>(
          id: bot,
          domainFn: (d, _) => 'Run ${d.runIndex}',
          measureFn: (d, _) => d.percent,
          data: data,
          labelAccessorFn: (d, _) => '${d.percent.toStringAsFixed(1)}%',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bot Win Shares (Stacked)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: charts.BarChart(
          series,
          animate: true,
          barGroupingType: charts.BarGroupingType.stacked,
          vertical: true,
          barRendererDecorator: charts.BarLabelDecorator<String>(),
          domainAxis: const charts.OrdinalAxisSpec(),
          primaryMeasureAxis: charts.PercentAxisSpec(),
        ),
      ),
    );
  }
}