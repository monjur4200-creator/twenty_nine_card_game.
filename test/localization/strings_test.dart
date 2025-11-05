import 'package:flutter_test/flutter_test.dart';
import 'package:twenty_nine_card_game/localization/strings.dart';

void main() {
  test('English strings return correctly', () {
    final s = Strings('en');
    expect(s.mainMenuTitle, 'Main Menu');
    expect(s.startGame, 'Start Game');
  });

  test('Bangla strings return correctly', () {
    final s = Strings('bn');
    expect(s.mainMenuTitle, 'মূল মেনু');
    expect(s.startGame, 'খেলা শুরু করুন');
  });
}
