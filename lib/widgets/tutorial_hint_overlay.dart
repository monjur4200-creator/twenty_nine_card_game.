import 'package:flutter/material.dart';

class TutorialHintOverlay extends StatelessWidget {
  final String hint;
  final VoidCallback onNext;

  const TutorialHintOverlay({
    super.key, // ✅ Use super parameter shorthand
    required this.hint,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        color: Colors.yellow.shade100,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(hint, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onNext,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}