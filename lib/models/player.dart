import 'package:firebase_auth/firebase_auth.dart';
import 'card29.dart';
import 'connection_type.dart';
import 'package:twenty_nine_card_game/models/login_method.dart';

class Player {
  final int id;
  final String name;
  final int teamId;

  final LoginMethod loginMethod;
  final ConnectionType connectionType;
  final User? firebaseUser;

  final List<Card29> _hand = [];
  List<Card29> get hand => List.unmodifiable(_hand);

  int score = 0;
  int tricksWon = 0;

  Player({
    required this.id,
    required this.name,
    required this.teamId,
    required this.loginMethod,
    required this.connectionType,
    this.firebaseUser,
  });

  // --- Hand Management ---
  void addCard(Card29 card) => _hand.add(card);
  void addCards(List<Card29> cards) => _hand.addAll(cards);
  void playCard(Card29 card) {
    if (!_hand.contains(card)) {
      throw StateError('Player $name does not have $card in hand');
    }
    _hand.remove(card);
  }

  void clearHand() => _hand.clear();

  void setHandForTest(List<Card29> cards) {
    clearHand();
    addCards(cards);
  }

  // --- Score & Round Management ---
  void incrementScore(int points) => score += points;
  void incrementTricksWon() => tricksWon++;
  void resetForNewRound() {
    clearHand();
    tricksWon = 0;
  }

  // --- Serialization ---
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'teamId': teamId,
        'score': score,
        'tricksWon': tricksWon,
        'hand': _hand.map((c) => c.toMap()).toList(),
        'loginMethod': loginMethod.name,
        'connectionType': connectionType.name,
        'firebaseUid': firebaseUser?.uid,
      };

  factory Player.fromMap(Map<String, dynamic> map) {
    final player = Player(
      id: map['id'] is int ? map['id'] as int : -1,
      name: map['name'] is String ? map['name'] as String : 'Unknown',
      teamId: map['teamId'] is int ? map['teamId'] as int : 0,
      loginMethod: LoginMethod.values.firstWhere(
        (m) => m.name == map['loginMethod'],
        orElse: () => LoginMethod.guest,
      ),
      connectionType: ConnectionType.values.firstWhere(
        (c) => c.name == map['connectionType'],
        orElse: () => ConnectionType.bluetooth,
      ),
      firebaseUser: null,
    );

    player.score = map['score'] is int ? map['score'] as int : 0;
    player.tricksWon = map['tricksWon'] is int ? map['tricksWon'] as int : 0;

    if (map['hand'] is List) {
      final cards = (map['hand'] as List)
          .map((c) => Card29.fromMap(Map<String, dynamic>.from(c)))
          .toList();
      player.addCards(cards);
    }

    return player;
  }

  // --- Debugging & Equality ---
  @override
  String toString() =>
      'Player($id, $name, team $teamId, score $score, tricks $tricksWon, hand=$_hand)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Player && id == other.id);

  @override
  int get hashCode => id.hashCode;
}
