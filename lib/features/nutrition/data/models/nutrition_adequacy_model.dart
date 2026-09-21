class NutritionAdequacyModel {
  final String caloricAdequacy; // within | below | above | unavailable
  final Map<String, double>? foodGroupProportions; // {go, grow, glow} in %
  final bool? foodGroupAdequate;
  final bool? nutritionallyAdequate;

  const NutritionAdequacyModel({
    required this.caloricAdequacy,
    this.foodGroupProportions,
    this.foodGroupAdequate,
    this.nutritionallyAdequate,
  });

  factory NutritionAdequacyModel.fromJson(Map<String, dynamic> json) {
    return NutritionAdequacyModel(
      caloricAdequacy: json['caloric_adequacy'] as String,
      foodGroupProportions: (json['food_group_proportions'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, (value as num).toDouble())),
      foodGroupAdequate: json['food_group_adequate'] as bool?,
      nutritionallyAdequate: json['nutritionally_adequate'] as bool?,
    );
  }

  bool get isWithin => caloricAdequacy == 'within';
  bool get isBelow => caloricAdequacy == 'below';
  bool get isAbove => caloricAdequacy == 'above';
  bool get isUnavailable => caloricAdequacy == 'unavailable';

  /// True only when we have a definite positive verdict — distinct from
  /// "not adequate" (false) and "we don't know yet" (null/unavailable).
  bool get isBalanced => nutritionallyAdequate == true;

  double get goPercent => foodGroupProportions?['go'] ?? 0;
  double get growPercent => foodGroupProportions?['grow'] ?? 0;
  double get glowPercent => foodGroupProportions?['glow'] ?? 0;

  String get caloricAdequacyLabel {
    switch (caloricAdequacy) {
      case 'within':
        return 'Fits your daily calorie needs';
      case 'below':
        return 'Below your per-meal calorie target';
      case 'above':
        return 'Above your per-meal calorie target';
      default:
        return 'Set your activity level to see this';
    }
  }

  @override
  String toString() =>
      'NutritionAdequacyModel(caloricAdequacy: $caloricAdequacy, '
      'nutritionallyAdequate: $nutritionallyAdequate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NutritionAdequacyModel &&
        other.caloricAdequacy == caloricAdequacy &&
        other.foodGroupAdequate == foodGroupAdequate &&
        other.nutritionallyAdequate == nutritionallyAdequate;
  }

  @override
  int get hashCode =>
      Object.hash(caloricAdequacy, foodGroupAdequate, nutritionallyAdequate);
}