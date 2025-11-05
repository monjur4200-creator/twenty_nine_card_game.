import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:twenty_nine_card_game/widgets/connection_selector.dart';
import 'package:twenty_nine_card_game/models/connection_type.dart';

void main() {
  group('ConnectionSelector Widget Tests', () {
    testWidgets('renders all connection buttons', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ConnectionSelector(onSelected: (_) {}),
        ),
      ));

      expect(find.byKey(const Key('connection_local')), findsOneWidget);
      expect(find.byKey(const Key('connection_bluetooth')), findsOneWidget);
      expect(find.byKey(const Key('connection_online')), findsOneWidget);
    });

    testWidgets('ConnectionSelector triggers selection', (tester) async {
      ConnectionType? selected;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ConnectionSelector(onSelected: (type) => selected = type),
        ),
      ));

      await tester.tap(find.byKey(const Key('connection_bluetooth')));
      await tester.pumpAndSettle();

      expect(selected, ConnectionType.bluetooth);
    });
  });
}