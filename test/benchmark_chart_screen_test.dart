import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/screens/benchmark_chart_screen.dart';
import 'package:twenty_nine_card_game/utils/benchmark_runner.dart';

void main() {
  testWidgets('BenchmarkChartScreen builds and shows title', (WidgetTester tester) async {
    // Act: pump the widget into the test environment
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BenchmarkChartScreen(results: [
            BenchmarkResult(runs: 1, exportMs: 50, mergeMs: 30),
            BenchmarkResult(runs: 2, exportMs: 70, mergeMs: 40),
          ]),
        ),
      ),
    );

    // Assert: verify the title is present
    expect(find.text('CSV Benchmark Results'), findsOneWidget);
  });
}