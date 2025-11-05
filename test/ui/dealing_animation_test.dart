import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/ui/dealing_animation.dart';
import 'package:twenty_nine_card_game/ui/card_widget.dart';

void main() {
  testWidgets('DealingAnimation deals 16 cards in first batch and triggers callback',
      (tester) async {
    bool callbackTriggered = false;
    final key = GlobalKey<DealingAnimationState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DealingAnimation(
            key: key,
            batchSize: 4, // 4 cards × 4 players = 16
            onBatchComplete: () {
              callbackTriggered = true;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // ✅ Expect 16 CardWidgets
    expect(find.byType(CardWidget), findsNWidgets(16));
    expect(callbackTriggered, isTrue);
  });

  testWidgets('DealingAnimation deals 16 more cards after startNextBatch',
      (tester) async {
    final key = GlobalKey<DealingAnimationState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DealingAnimation(
            key: key,
            batchSize: 4,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(CardWidget), findsNWidgets(16));

    // Trigger second batch
    key.currentState!.startNextBatch();
    await tester.pumpAndSettle();

    // ✅ Expect 32 total cards (16 + 16)
    expect(find.byType(CardWidget), findsNWidgets(32));
  });
}
