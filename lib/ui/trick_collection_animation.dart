import 'package:flutter/material.dart';
import 'package:twenty_nine_card_game/models/card29.dart';
import 'package:twenty_nine_card_game/ui/card_widget.dart';

/// Animates trick cards flying to the winner.
class TrickCollectionAnimation extends StatefulWidget {
  final List<Card29> trickCards;
  final String winnerId;
  final VoidCallback? onComplete;

  const TrickCollectionAnimation({
    super.key,
    required this.trickCards,
    required this.winnerId,
    this.onComplete,
  });

  @override
  State<TrickCollectionAnimation> createState() => _TrickCollectionAnimationState();
}

class _TrickCollectionAnimationState extends State<TrickCollectionAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<Offset>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    final total = widget.trickCards.length;
    final winnerOffset = _winnerOffset(widget.winnerId);

    _animations = List.generate(total, (i) {
      final startInterval = i / total;
      final endInterval = (i + 1) / total;

      return Tween<Offset>(begin: Offset.zero, end: winnerOffset).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(startInterval, endInterval, curve: Curves.easeInOut),
        ),
      );
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  Offset _winnerOffset(String id) {
    switch (id) {
      case "Player 1":
        return const Offset(0, 2);   // Bottom
      case "Player 2":
        return const Offset(-2, 0);  // Left
      case "Player 3":
        return const Offset(0, -2);  // Top
      case "Player 4":
        return const Offset(2, 0);   // Right
      default:
        return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(widget.trickCards.length, (i) {
        return SlideTransition(
          position: _animations[i],
          child: CardWidget(
            key: ValueKey('trick_card_$i'),
            card: widget.trickCards[i],
            width: 40,
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
