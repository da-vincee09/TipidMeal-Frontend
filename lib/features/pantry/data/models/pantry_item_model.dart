class PantryItemModel {
  final String id;
  final String ingredient;
  final double quantity;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PantryItemModel({
    required this.id,
    required this.ingredient,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PantryItemModel.fromJson(Map<String, dynamic> json) {
    return PantryItemModel(
      id: json['id'] as String,
      ingredient: json['ingredient'] as String,
      quantity: _parseDecimal(json['quantity']),
      unit: json['unit'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static double _parseDecimal(dynamic value) {
    if (value is String) return double.parse(value);
    if (value is num) return value.toDouble();
    throw FormatException('Unexpected quantity type: ${value.runtimeType}');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredient': ingredient,
      'quantity': quantity,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PantryItemModel copyWith({
    String? id,
    String? ingredient,
    double? quantity,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PantryItemModel(
      id: id ?? this.id,
      ingredient: ingredient ?? this.ingredient,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Trims trailing zeros for display (e.g. `500` instead of `500.0`).
  String get displayQuantity {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toString();
  }

  @override
  String toString() =>
      'PantryItemModel(id: $id, ingredient: $ingredient, '
      'quantity: $quantity, unit: $unit)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PantryItemModel &&
        other.id == id &&
        other.ingredient == ingredient &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, ingredient, quantity, unit, createdAt, updatedAt);
}