import 'package:flutter/material.dart';
import '../utils/game_manager.dart';

class ModifierControls extends StatelessWidget {
  final GameManager manager;
  final VoidCallback onChanged;

  const ModifierControls({
    super.key,
    required this.manager,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = manager.roundStarted; // lock modifiers once round starts

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // Single Hand (only before round starts, no modifier yet)
        ElevatedButton(
          onPressed: !disabled && manager.modifier == RoundModifier.none
              ? () {
                  manager.applySingleHand();
                  onChanged();
                }
              : null,
          child: const Text('Single Hand'),
        ),

        // Double (only before round starts, no modifier yet)
        ElevatedButton(
          onPressed: !disabled && manager.modifier == RoundModifier.none
              ? () {
                  manager.applyDouble();
                  onChanged();
                }
              : null,
          child: const Text('Double'),
        ),

        // Re‑double (only before round starts, after Double)
        ElevatedButton(
          onPressed: !disabled && manager.modifier == RoundModifier.double
              ? () {
                  manager.applyRedouble();
                  onChanged();
                }
              : null,
          child: const Text('Re‑double'),
        ),

        // Full Set (only before round starts, after Re‑double)
        ElevatedButton(
          onPressed: !disabled && manager.modifier == RoundModifier.redouble
              ? () {
                  manager.applyFullSet();
                  onChanged();
                }
              : null,
          child: const Text('Full Set'),
        ),
      ],
    );
  }
}
