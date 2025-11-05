import 'package:flutter/material.dart';
import 'package:twenty_nine_card_game/screens/bot_stats_dashboard.dart';
import 'benchmark_chart_screen.dart';
import 'package:twenty_nine_card_game/utils/benchmark_runner.dart';
import 'package:twenty_nine_card_game/utils/csv_utils.dart';
import 'package:twenty_nine_card_game/utils/meta_health.dart'; // ✅ new import

class CombinedDashboard extends StatefulWidget {
  final List<Map<String, int>> runs;
  final List<BenchmarkResult> benchmarks;

  const CombinedDashboard({
    super.key,
    required this.runs,
    required this.benchmarks,
  });

  @override
  State<CombinedDashboard> createState() => _CombinedDashboardState();
}

class _CombinedDashboardState extends State<CombinedDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Volatility values
  late int crownChanges;
  late double volatilityPercent;
  late String volatilityLabel;
  late Color volatilityColor;

  // Meta Health Index values
  late double metaHealthIndex;
  late String metaHealthLabel;
  late Color metaHealthColor;

  // Animation controller for pulsing badge
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateMetrics();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    );

    // Pulse only if meta health is not healthy
    if (metaHealthIndex < 80) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _calculateMetrics() {
    // Normalize runs into percentages
    final normalizedRuns = widget.runs.map(normalizeWinCounts).toList();

    // Track top bot per run for volatility
    final topBotPerRun = <String>[];
    for (final run in normalizedRuns) {
      String? topBot;
      double topPercent = -1;
      run.forEach((bot, percent) {
        if (percent > topPercent) {
          topBot = bot;
          topPercent = percent;
        }
      });
      if (topBot != null) topBotPerRun.add(topBot!);
    }

    crownChanges = 0;
    for (int i = 1; i < topBotPerRun.length; i++) {
      if (topBotPerRun[i] != topBotPerRun[i - 1]) {
        crownChanges++;
      }
    }
    volatilityPercent = topBotPerRun.length > 1
        ? (crownChanges / (topBotPerRun.length - 1)) * 100
        : 0.0;

    if (volatilityPercent < 30) {
      volatilityLabel = 'Stable';
      volatilityColor = Colors.green.shade700;
    } else if (volatilityPercent < 60) {
      volatilityLabel = 'Moderate';
      volatilityColor = Colors.orange.shade700;
    } else {
      volatilityLabel = 'Volatile';
      volatilityColor = Colors.red.shade700;
    }

    // --- Meta Health Index ---
    final normalizedRunsDouble = normalizedRuns
        .map((r) => r.map((k, v) => MapEntry(k, v.toDouble())))
        .toList();

    metaHealthIndex = calculateMetaHealthIndex(
      normalizedRuns: normalizedRunsDouble,
    );

    final classification = classifyMetaHealth(
      metaHealthIndex,
      normalizedRuns: normalizedRunsDouble,
    );

    metaHealthLabel = classification.label;
    metaHealthColor = classification.color == 'green'
        ? Colors.green.shade700
        : classification.color == 'orange'
            ? Colors.orange.shade700
            : Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Dashboard'),
        actions: [
          Tooltip(
            message: 'Tap to view meta health details',
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(2); // Jump to Summary tab
              },
              child: ScaleTransition(
                scale: metaHealthIndex < 80
                    ? _pulseController
                    : const AlwaysStoppedAnimation(1.0),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Chip(
                    label: Text(
                      'MHI ${metaHealthIndex.toStringAsFixed(0)} – $metaHealthLabel',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: metaHealthColor,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Bot Performance'),
            Tab(icon: Icon(Icons.speed), text: 'Benchmarks'),
            Tab(icon: Icon(Icons.summarize), text: 'Summary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BotStatsDashboard(runs: widget.runs),
          BenchmarkChartScreen(results: widget.benchmarks),
          _buildSummaryTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          // ✅ Updated to use withValues instead of deprecated withOpacity
          color: metaHealthColor.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Meta Health Index: ${metaHealthIndex.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: metaHealthColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  metaHealthLabel,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Add volatility/benchmark summary cards here...
      ],
    );
  }
}
