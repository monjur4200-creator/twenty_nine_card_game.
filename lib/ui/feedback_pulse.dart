import 'package:flutter/material.dart';

/// Wraps any widget with a pulse animation for feedback.
/// Use for bid confirmation, trump reveal, trick win glow, etc.
class FeedbackPulse extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Duration duration;
  final double scaleFactor;

  const FeedbackPulse({
    super.key,
    required this.child,
    required this.trigger,
    this.duration = const Duration(milliseconds: 500),
    this.scaleFactor = 1.2,
  });

  @override
  State<FeedbackPulse> createState() => _FeedbackPulseState();
}

class _FeedbackPulseState extends State<FeedbackPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scale = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.trigger) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void didUpdateWidget(covariant FeedbackPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
