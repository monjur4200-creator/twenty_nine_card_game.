import 'package:flutter/material.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import '../ui/card_widget.dart';
import 'package:twenty_nine_card_game/services/trick_evaluator.dart';

class GameTableScreen extends StatefulWidget {
  const GameTableScreen({super.key});

  @override
  State<GameTableScreen> createState() => _GameTableScreenState();
}

class _GameTableScreenState extends State<GameTableScreen> {
  List<Card29> bottomHand = [
    const Card29(Suit.hearts, Rank.ace),
    const Card29(Suit.spades, Rank.king),
    const Card29(Suit.clubs, Rank.queen),
    const Card29(Suit.diamonds, Rank.jack),
    const Card29(Suit.hearts, Rank.ten),
  ];

  List<Card29> topHand = [
    const Card29(Suit.diamonds, Rank.ace),
    const Card29(Suit.clubs, Rank.king),
    const Card29(Suit.spades, Rank.queen),
  ];

  List<Card29> leftHand = [
    const Card29(Suit.hearts, Rank.nine),
    const Card29(Suit.clubs, Rank.jack),
    const Card29(Suit.spades, Rank.ten),
  ];

  List<Card29> rightHand = [
    const Card29(Suit.diamonds, Rank.king),
    const Card29(Suit.hearts, Rank.queen),
    const Card29(Suit.clubs, Rank.ace),
  ];

  List<Card29> trickPile = [];
  String? trickWinner;
  final Suit trumpSuit = Suit.hearts;

  void _playCard(List<Card29> hand, int index, String playerName) {
    setState(() {
      trickPile.add(hand[index]);
      hand.removeAt(index);
    });
  }

  void _clearTrick() {
    setState(() {
      final evaluator = TrickEvaluator(trumpSuit: trumpSuit);
      trickWinner = evaluator.determineWinner(trickPile);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            trickPile.clear();
            trickWinner = null;
          });
        }
      });
    });
  }

  Widget _buildFannedHand(
    List<Card29> cards,
    String playerName, {
    double spreadAngle = 0.3,
    double cardWidth = 60,
    bool isBottom = false,
  }) {
    final middle = (cards.length - 1) / 2;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(playerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: cardWidth * 1.6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < cards.length; i++)
                GestureDetector(
                  onTap: isBottom ? () => _playCard(cards, i, playerName) : null,
                  child: Transform.rotate(
                    angle: (i - middle) * (spreadAngle / middle),
                    child: Transform.translate(
                      offset: Offset((i - middle) * (cardWidth * 0.4), 0),
                      child: CardWidget(card: cards[i], width: cardWidth),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalFannedHand(
    List<Card29> cards,
    String playerName, {
    double spreadAngle = 0.3,
    double cardWidth = 50,
  }) {
    final middle = (cards.length - 1) / 2;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(playerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          width: cardWidth * 1.6,
          height: cardWidth * 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < cards.length; i++)
                Transform.rotate(
                  angle: (i - middle) * (spreadAngle / middle),
                  child: Transform.translate(
                    offset: Offset(0, (i - middle) * (cardWidth * 0.4)),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: CardWidget(card: cards[i], width: cardWidth),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final canClear = trickPile.length >= 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Table", key: Key('gameScreenTitle')),
        actions: [
          if (canClear)
            IconButton(
              key: const Key('clearTrickButton'),
              icon: const Icon(Icons.refresh),
              tooltip: "Clear Trick",
              onPressed: _clearTrick,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/table/felt.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildFannedHand(
                bottomHand,
                "You",
                spreadAngle: 0.5,
                cardWidth: 70,
                isBottom: true,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: _buildFannedHand(
                topHand,
                "Player 2",
                spreadAngle: 0.4,
                cardWidth: 50,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildVerticalFannedHand(
                leftHand,
                "Player 3",
                spreadAngle: 0.5,
                cardWidth: 50,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _buildVerticalFannedHand(
                rightHand,
                "Player 4",
                spreadAngle: 0.5,
                cardWidth: 50,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: trickPile
                    .map((card) => CardWidget(card: card, width: 60))
                    .toList(),
              ),
            ),
            if (trickWinner != null)
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Trick Winner: $trickWinner",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
