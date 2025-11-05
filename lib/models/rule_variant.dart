class RuleVariant {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;
  final String region; // e.g., "Dhaka", "Sylhet", "Kolkata"
  final int complexityLevel; // 1 = basic, 2 = intermediate, 3 = advanced

  const RuleVariant({
    required this.id,
    required this.name,
    required this.description,
    this.isEnabled = false,
    this.region = 'global',
    this.complexityLevel = 1,
  });

  RuleVariant copyWith({
    String? id,
    String? name,
    String? description,
    bool? isEnabled,
    String? region,
    int? complexityLevel,
  }) {
    return RuleVariant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      region: region ?? this.region,
      complexityLevel: complexityLevel ?? this.complexityLevel,
    );
  }
}