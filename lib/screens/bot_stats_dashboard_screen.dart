import 'package:flutter/material.dart';
import 'bot_stats_dashboard.dart'; // make sure this path is correct

class BotStatsDashboardScreen extends StatelessWidget {
  final List<Map<String, int>> runs;

  const BotStatsDashboardScreen({
    super.key,
    required this.runs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bot Stats Dashboard Screen')),
      body: BotStatsDashboard(runs: runs),
    );
  }
}