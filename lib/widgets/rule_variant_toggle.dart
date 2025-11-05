import 'package:flutter/material.dart';
import '../models/rule_variant.dart';

class RuleVariantToggle extends StatelessWidget {
  final RuleVariant variant;
  final ValueChanged<bool> onChanged;

  const RuleVariantToggle({
    super.key, // ✅ Fixes the analyzer info: use_super_parameters
    required this.variant,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(variant.name),
      subtitle: Text(variant.description),
      value: variant.isEnabled,
      onChanged: onChanged,
    );
  }
}