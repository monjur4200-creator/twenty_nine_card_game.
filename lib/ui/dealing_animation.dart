import 'package:flutter/material.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/ui/card_widget.dart';

class DealingAnimation extends StatefulWidget {
  final int cardsPerPlayer;
  final int batchSize;
  final Duration duration;
  final VoidCallback? onBatchComplete;

  const DealingAnimation({
    super.key,
    this.cardsPerPlayer = 8,
    this.batchSize = 4,
    this.duration = const Duration(seconds: 4),
    this.onBatchComplete,
  });

  @override
  State<DealingAnimation> createState() => DealingAnimationState();
}

class DealingAnimationState extends State<DealingAnimation>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<Offset>> _animations = [];
  int _currentBatch = 1;

  @override
  void initState() {
    super.initState();
    _startBatch();
  }

  void _startBatch() {
    final totalCards = 4 * widget.batchSize;
    final controller =
        AnimationController(vsync: this, duration: widget.duration);
    _controllers.add(controller);

    final batchAnimations = List.generate(totalCards, (i) {
      final playerIndex = i % 4;
      const start = Offset(0, 0);
      final end = _playerOffset(playerIndex);

      final startInterval = i / totalCards;
      final endInterval = (i + 1) / totalCards;

      return Tween<Offset>(begin: start, end: end).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
        ),
      );
    });

    _animations.addAll(batchAnimations);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _currentBatch == 1) {
        widget.onBatchComplete?.call();
      }
    });

    controller.forward();
  }

  void startNextBatch() {
    if (_currentBatch == 1) {
      setState(() {
        _currentBatch = 2;
        _startBatch();
      });
    }
  }

  Offset _playerOffset(int playerIndex) {
    switch (playerIndex) {
      case 0:
        return const Offset(0, 2); // Bottom
      case 1:
        return const Offset(-2, 0); // Left
      case 2:
        return const Offset(0, -2); // Top
      case 3:
        return const Offset(2, 0); // Right
      default:
        return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(_animations.length, (i) {
        return SlideTransition(
          position: _animations[i],
          child: _buildCard(i),
        );
      }),
    );
  }

  Widget _buildCard(int i) {
    final suits = [Suit.spades, Suit.hearts, Suit.diamonds, Suit.clubs];
    final ranks = [
      Rank.seven,
      Rank.eight,
      Rank.nine,
      Rank.ten,
      Rank.jack,
      Rank.queen,
      Rank.king,
      Rank.ace,
    ];

    final suit = suits[i % 4];
    final rank = ranks[(i ~/ 4) % ranks.length];

    return CardWidget(
      key: ValueKey('card_$i'),
      card: Card29(suit, rank),
      width: 40,
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
