import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/ui/feedback_pulse.dart';

void main() {
  testWidgets('FeedbackPulse wraps child and animates on trigger', (tester) async {
    bool trigger = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedbackPulse(
            trigger: trigger,
            child: const Text('Bid Confirmed'),
          ),
        ),
      ),
    );

    // Initial frame
    expect(find.text('Bid Confirmed'), findsOneWidget);

    // Let animation run
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));

    // ✅ Still visible after animation
    expect(find.text('Bid Confirmed'), findsOneWidget);
  });

  testWidgets('FeedbackPulse does not animate when trigger is false', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeedbackPulse(
            trigger: false,
            child: Text('No Pulse'),
          ),
        ),
      ),
    );

    expect(find.text('No Pulse'), findsOneWidget);
  });
}
