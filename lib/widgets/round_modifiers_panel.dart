import 'package:flutter/material.dart';
import '../utils/game_manager.dart';

class RoundModifiersPanel extends StatelessWidget {
  final GameManager manager;
  final ValueChanged<RoundModifier> onChanged;

  const RoundModifiersPanel({
    super.key,
    required this.manager,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildChoice(context, 'None', RoundModifier.none),
        _buildChoice(context, 'Double', RoundModifier.double),
        _buildChoice(context, 'Re‑double', RoundModifier.redouble),
        _buildChoice(context, 'Full Set', RoundModifier.fullSet),
        _buildChoice(context, 'Single Hand', RoundModifier.singleHand),
      ],
    );
  }

  Widget _buildChoice(BuildContext context, String label, RoundModifier value) {
    final isSelected = manager.modifier == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onChanged(value),
      selectedColor: Colors.blue.shade200,
    );
  }
}