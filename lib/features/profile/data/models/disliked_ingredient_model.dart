class DislikedIngredientModel {
  final String id;
  final String ingredient;

  DislikedIngredientModel({
    required this.id, 
    required this.ingredient
  });

  factory DislikedIngredientModel.fromJson(Map<String, dynamic> json) {
    return DislikedIngredientModel(
      id: json['id'] as String, 
      ingredient: json['ingredient'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredient': ingredient,
    };
  }

  DislikedIngredientModel copyWith({
    String? id,
    String? ingredient,
  }) {
    return DislikedIngredientModel(
      id: id ?? this.id, 
      ingredient: ingredient ?? this.ingredient,
    );
  }

  @override
  String toString() => 'DislikedIngredientModel(id: $id, ingredient: $ingredient)';
 
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DislikedIngredientModel &&
        other.id == id &&
        other.ingredient == ingredient;
  }
 
  @override
  int get hashCode => Object.hash(id, ingredient);
  
}