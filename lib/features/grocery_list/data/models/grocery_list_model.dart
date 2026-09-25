import 'package:meal_recommendation_app/core/utils/ingredient_display.dart';

class GroceryListItemModel {
  final String ingredient;
  final String unit;
  final double requiredQuantity;
  final double pantryQuantity;
  final double quantityToBuy;
  final double? estimatedCost;

  const GroceryListItemModel({
    required this.ingredient,
    required this.unit,
    required this.requiredQuantity,
    required this.pantryQuantity,
    required this.quantityToBuy,
    this.estimatedCost,
  });

  factory GroceryListItemModel.fromJson(Map<String, dynamic> json) {
    return GroceryListItemModel(
      ingredient: json['ingredient'] as String,
      unit: json['unit'] as String,
      requiredQuantity: _parseDecimal(json['required_quantity']),
      pantryQuantity: _parseDecimal(json['pantry_quantity']),
      quantityToBuy: _parseDecimal(json['quantity_to_buy']),
      estimatedCost: _parseNullableDecimal(json['estimated_cost']),
    );
  }

  static double _parseDecimal(dynamic value) {
    if (value is String) return double.parse(value);
    if (value is num) return value.toDouble();
    throw FormatException('Unexpected quantity type: ${value.runtimeType}');
  }

  static double? _parseNullableDecimal(dynamic value) {
    if (value == null) return null;
    if (value is String) return double.parse(value);
    if (value is num) return value.toDouble();
    throw FormatException('Unexpected quantity type: ${value.runtimeType}');
  }

  /// Trims trailing zeros for display (e.g. `2` instead of `2.0`).
  static String _trim(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  // "string_beans" -> "String Beans" — always use this for display,
  /// keep `ingredient` for API calls and comparisons.
  String get displayName => formatIngredientName(ingredient);

  String get displayQuantityToBuy => _trim(quantityToBuy);
  String get displayRequiredQuantity => _trim(requiredQuantity);
  String get displayPantryQuantity => _trim(pantryQuantity);

  /// e.g. "₱210.00" — always 2 decimal places, unlike the trimmed
  /// quantity getters above, since money shouldn't drop trailing zeros.
  String? get displayEstimatedCost {
    if (estimatedCost == null) return null;
    return '₱${estimatedCost!.toStringAsFixed(2)}';
  }

  /// True when the pantry has none of this ingredient at all, as
  /// opposed to just not enough — useful for the UI to distinguish
  /// "buy some" from "buy more".
  bool get hasNoneInPantry => pantryQuantity == 0;

  @override
  String toString() =>
      'GroceryListItemModel(ingredient: $ingredient, quantityToBuy: '
      '$quantityToBuy $unit, estimatedCost: $estimatedCost)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroceryListItemModel &&
        other.ingredient == ingredient &&
        other.unit == unit &&
        other.requiredQuantity == requiredQuantity &&
        other.pantryQuantity == pantryQuantity &&
        other.quantityToBuy == quantityToBuy &&
        other.estimatedCost == estimatedCost;
  }

  @override
  int get hashCode => Object.hash(
        ingredient,
        unit,
        requiredQuantity,
        pantryQuantity,
        quantityToBuy,
        estimatedCost,
      );
}

class GroceryListResponseModel {
  final DateTime startDate;
  final DateTime endDate;
  final List<GroceryListItemModel> items;
  final double? totalEstimatedCost;

  const GroceryListResponseModel({
    required this.startDate,
    required this.endDate,
    required this.items,
    this.totalEstimatedCost,
  });

  factory GroceryListResponseModel.fromJson(Map<String, dynamic> json) {
    return GroceryListResponseModel(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => GroceryListItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalEstimatedCost: GroceryListItemModel._parseNullableDecimal(
        json['total_estimated_cost'],
      ),
    );
  }

  /// e.g. "₱222.21" — null when no items in the list had a known price
  /// (matches the backend's has_any_priced_item logic).
  String? get displayTotalEstimatedCost {
    if (totalEstimatedCost == null) return null;
    return '₱${totalEstimatedCost!.toStringAsFixed(2)}';
  }
}