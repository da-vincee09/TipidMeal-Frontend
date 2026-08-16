class PantryItemCreateRequest {
  final String ingredient;
  final double quantity;
  final String unit;

  const PantryItemCreateRequest({
    required this.ingredient,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredient': ingredient,
      'quantity': quantity,
      'unit': unit,
    };
  }
}