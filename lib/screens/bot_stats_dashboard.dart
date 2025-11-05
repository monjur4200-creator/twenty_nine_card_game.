import 'package:flutter/material.dart';

class BotStatsDashboard extends StatelessWidget {
  final List<Map<String, int>> runs;

  const BotStatsDashboard({
    super.key,
    required this.runs,   // ✅ initialize the final field
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Bot Stats Dashboard (to be implemented)\nRuns count: ${runs.length}',
        textAlign: TextAlign.center,
      ),
    );
  }
}
