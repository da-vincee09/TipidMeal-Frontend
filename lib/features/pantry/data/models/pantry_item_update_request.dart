class PantryItemUpdateRequest {
  final String? ingredient;
  final double? quantity;
  final String? unit;

  const PantryItemUpdateRequest({
    this.ingredient,
    this.quantity,
    this.unit,
  });

  /// Only includes fields that were actually set, so partial updates don't
  /// accidentally send `null` for fields the user didn't touch.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (ingredient != null) json['ingredient'] = ingredient;
    if (quantity != null) json['quantity'] = quantity;
    if (unit != null) json['unit'] = unit;
    return json;
  }
}