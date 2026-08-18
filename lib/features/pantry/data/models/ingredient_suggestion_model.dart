class IngredientSuggestionModel {
  final String ingredient;
  final List<String> units;

  const IngredientSuggestionModel({
    required this.ingredient,
    required this.units,
  });

  factory IngredientSuggestionModel.fromJson(Map<String, dynamic> json) {
    return IngredientSuggestionModel(
      ingredient: json['ingredient'] as String,
      units: (json['units'] as List<dynamic>).cast<String>(),
    );
  }

  /// True when every meal using this ingredient uses the same unit —
  /// safe to auto-select without asking the user.
  bool get hasSingleUnit => units.length == 1;
}