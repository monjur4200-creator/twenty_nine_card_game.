import 'package:flutter/material.dart';
import '../models/rule_variant.dart';
import '../widgets/rule_variant_toggle.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key}); // ✅ Use super.key shorthand

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<RuleVariant> variants = [
    const RuleVariant(
      id: 'blind_trump',
      name: 'Blind Trump',
      description: 'Reveal trump without suit knowledge',
    ),
    const RuleVariant(
      id: 'double_bid',
      name: 'Double Bid',
      description: 'Allow bidding twice per round',
    ),
    const RuleVariant(
      id: 'partner_signal',
      name: 'Partner Signaling',
      description: 'Enable non-verbal partner hints',
    ),
  ];

  void toggleVariant(int index, bool value) {
    setState(() {
      variants[index] = variants[index].copyWith(isEnabled: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rule Variants')),
      body: ListView.builder(
        itemCount: variants.length,
        itemBuilder: (context, index) {
          return RuleVariantToggle(
            variant: variants[index],
            onChanged: (value) => toggleVariant(index, value),
          );
        },
      ),
    );
  }
}