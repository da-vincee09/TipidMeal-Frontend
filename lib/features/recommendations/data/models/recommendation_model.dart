import 'package:meal_recommendation_app/features/meals/data/models/meal_model.dart';

class IngredientAdaptationModel {
  final String ingredient;
  final String action; // retain | insufficient | substitute | omit | unavailable
  final String? replacement;
  final double? availableQuantity;
  final double? requiredQuantity;
  final String? unit;

  const IngredientAdaptationModel({
    required this.ingredient,
    required this.action,
    this.replacement,
    this.availableQuantity,
    this.requiredQuantity,
    this.unit,
  });

  factory IngredientAdaptationModel.fromJson(Map<String, dynamic> json) {
    return IngredientAdaptationModel(
      ingredient: json['ingredient'] as String,
      action: json['action'] as String,
      replacement: json['replacement'] as String?,
      availableQuantity: _parseNullableDecimal(json['available_quantity']),
      requiredQuantity: _parseNullableDecimal(json['required_quantity']),
      unit: json['unit'] as String?,
    );
  }

  static double? _parseNullableDecimal(dynamic value) {
    if (value == null) return null;
    if (value is String) return double.parse(value);
    if (value is num) return value.toDouble();
    throw FormatException('Unexpected quantity type: ${value.runtimeType}');
  }

  bool get isRetained => action == 'retain';
  bool get isInsufficient => action == 'insufficient';
  bool get isSubstitute => action == 'substitute';
  bool get isOmitted => action == 'omit';
  bool get isUnavailable => action == 'unavailable';

  @override
  String toString() =>
      'IngredientAdaptationModel(ingredient: $ingredient, action: $action, '
      'replacement: $replacement)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IngredientAdaptationModel &&
        other.ingredient == ingredient &&
        other.action == action &&
        other.replacement == replacement &&
        other.availableQuantity == availableQuantity &&
        other.requiredQuantity == requiredQuantity &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(
        ingredient,
        action,
        replacement,
        availableQuantity,
        requiredQuantity,
        unit,
      );
}

class MealAdaptationModel {
  final String decision; // adapt | fallback (fallback never actually
  // reaches the client — service.py filters those out server-side —
  // but we handle it defensively anyway)
  final List<IngredientAdaptationModel> ingredients;

  const MealAdaptationModel({
    required this.decision,
    required this.ingredients,
  });

  factory MealAdaptationModel.fromJson(Map<String, dynamic> json) {
    return MealAdaptationModel(
      decision: json['decision'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) =>
              IngredientAdaptationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isFallback => decision == 'fallback';

  List<IngredientAdaptationModel> get insufficientIngredients =>
      ingredients.where((i) => i.isInsufficient).toList();
  List<IngredientAdaptationModel> get substitutedIngredients =>
      ingredients.where((i) => i.isSubstitute).toList();
  List<IngredientAdaptationModel> get omittedIngredients =>
      ingredients.where((i) => i.isOmitted).toList();

  bool get hasAdaptations =>
      insufficientIngredients.isNotEmpty ||
      substitutedIngredients.isNotEmpty ||
      omittedIngredients.isNotEmpty;

  @override
  String toString() =>
      'MealAdaptationModel(decision: $decision, ingredients: $ingredients)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealAdaptationModel &&
        other.decision == decision &&
        _listEquals(other.ingredients, ingredients);
  }

  static bool _listEquals(
    List<IngredientAdaptationModel> a,
    List<IngredientAdaptationModel> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(decision, Object.hashAll(ingredients));
}

class RecommendationModel {
  final MealModel meal;
  final double coverage;
  final double budgetScore;
  final double skillScore;
  final double allergyScore;
  final double dislikedScore;
  final double hybridScore;
  final MealAdaptationModel adaptation;

  const RecommendationModel({
    required this.meal,
    required this.coverage,
    required this.budgetScore,
    required this.skillScore,
    required this.allergyScore,
    required this.dislikedScore,
    required this.hybridScore,
    required this.adaptation,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      meal: MealModel.fromJson(json['meal'] as Map<String, dynamic>),
      coverage: _parseDouble(json['coverage']),
      budgetScore: _parseDouble(json['budget_score']),
      skillScore: _parseDouble(json['skill_score']),
      allergyScore: _parseDouble(json['allergy_score']),
      dislikedScore: _parseDouble(json['disliked_score']),
      hybridScore: _parseDouble(json['hybrid_score']),
      adaptation:
          MealAdaptationModel.fromJson(json['adaptation'] as Map<String, dynamic>),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is String) return double.parse(value);
    if (value is num) return value.toDouble();
    throw FormatException('Unexpected numeric type: ${value.runtimeType}');
  }

  /// e.g. "72%" — coverage is a 0.0–1.0 fraction from the backend.
  String get displayCoveragePercent => '${(coverage * 100).round()}%';

  /// e.g. "85" — hybrid_score is also a 0.0–1.0 fraction.
  String get displayHybridScore => (hybridScore * 100).round().toString();

  @override
  String toString() =>
      'RecommendationModel(meal: ${meal.name}, hybridScore: $hybridScore, '
      'decision: ${adaptation.decision})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendationModel &&
        other.meal == meal &&
        other.coverage == coverage &&
        other.budgetScore == budgetScore &&
        other.skillScore == skillScore &&
        other.allergyScore == allergyScore &&
        other.dislikedScore == dislikedScore &&
        other.hybridScore == hybridScore &&
        other.adaptation == adaptation;
  }

  @override
  int get hashCode => Object.hash(
        meal,
        coverage,
        budgetScore,
        skillScore,
        allergyScore,
        dislikedScore,
        hybridScore,
        adaptation,
      );
}