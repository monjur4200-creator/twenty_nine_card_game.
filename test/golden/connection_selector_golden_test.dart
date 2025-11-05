import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/widgets/connection_selector.dart';

void main() {
  testWidgets('ConnectionSelector golden test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: RepaintBoundary(
            child: Scaffold(
              body: ConnectionSelector(
                onSelected: (_) {}, // ✅ only required parameter
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(ConnectionSelector),
      matchesGoldenFile('goldens/connection_selector.png'),
    );
  });
}