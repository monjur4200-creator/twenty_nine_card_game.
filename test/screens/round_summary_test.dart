import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/screens/round_summary.dart';
import 'package:twenty_nine_card_game/screens/main_menu.dart';
import 'package:twenty_nine_card_game/services/firebase_service.dart';
import 'package:twenty_nine_card_game/services/auth_service.dart';
import 'package:twenty_nine_card_game/services/presence_service.dart';
import 'package:twenty_nine_card_game/services/room_service.dart';
import 'package:twenty_nine_card_game/localization/strings.dart';

class MockFirebaseService extends Fake implements FirebaseService {}
class MockAuthService extends Fake implements AuthService {}
class MockPresenceService extends Fake implements PresenceService {}
class MockRoomService extends Fake implements RoomService {}

class MockStrings extends Fake implements Strings {
  @override String get viewRules => 'View Rules';
  @override String get mainMenuTitle => 'Main Menu';
  @override String get startGame => 'Start Game';
  @override String get createRoom => 'Create Room';
  @override String get enterRoomId => 'Enter Room ID';
  @override String get joinRoom => 'Join Room';
  @override String get loginAndConnectWarning => 'Please log in and select a connection type.';
  @override String get pleaseEnterRoomId => 'Please enter a room ID.';
  @override String get enjoyGame => 'Enjoy the game!';
  @override String get settings => 'Settings';
}

void main() {
  testWidgets('RoundSummary displays scores and navigates to MainMenu', (WidgetTester tester) async {
    final mockFirebase = MockFirebaseService();
    final mockStrings = MockStrings();
    final mockAuth = MockAuthService();
    final mockPresence = MockPresenceService();
    final mockRoom = MockRoomService();

    await tester.pumpWidget(
      MaterialApp(
        home: RoundSummary(
          team1Score: 22,
          team2Score: 18,
          roundNumber: 3,
          firebaseService: mockFirebase,
          strings: mockStrings,
          authService: mockAuth,
          presenceService: mockPresence,
          roomService: mockRoom,
        ),
      ),
    );

    expect(find.text('📊 Round 3 Results'), findsOneWidget);
    expect(find.text('Team 1'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(find.text('Team 2'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Main Menu'), findsOneWidget);

    await tester.tap(find.byKey(const Key('mainMenuButton')));
    await tester.pumpAndSettle();

    expect(find.byType(MainMenu), findsOneWidget);
  });
}