class MealIngredientModel {
  final String id;
  final String ingredient;
  final double quantity;
  final String unit;
  final bool isOptional;

  const MealIngredientModel({
    required this.id,
    required this.ingredient,
    required this.quantity,
    required this.unit,
    required this.isOptional,
  });

  factory MealIngredientModel.fromJson(Map<String, dynamic> json) {
    return MealIngredientModel(
      id: json['id'] as String,
      ingredient: json['ingredient'] as String,
      quantity: _parseDecimal(json['quantity']),
      unit: json['unit'] as String,
      isOptional: json['is_optional'] as bool,
    );
  }

  static double _parseDecimal(dynamic value) {
    if (value is String) return double.parse(value);
    if (value is num) return value.toDouble();
    throw FormatException('Unexpected quantity type: ${value.runtimeType}');
  }

  String get displayQuantity {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredient': ingredient,
      'quantity': quantity,
      'unit': unit,
      'is_optional': isOptional,
    };
  }

  @override
  String toString() =>
      'MealIngredientModel(id: $id, ingredient: $ingredient, '
      'quantity: $quantity, unit: $unit, isOptional: $isOptional)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealIngredientModel &&
        other.id == id &&
        other.ingredient == ingredient &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.isOptional == isOptional;
  }

  @override
  int get hashCode => Object.hash(id, ingredient, quantity, unit, isOptional);
}

class MealInstructionModel {
  final String id;
  final int stepNumber;
  final String instruction;

  const MealInstructionModel({
    required this.id,
    required this.stepNumber,
    required this.instruction,
  });

  factory MealInstructionModel.fromJson(Map<String, dynamic> json) {
    return MealInstructionModel(
      id: json['id'] as String,
      stepNumber: json['step_number'] as int,
      instruction: json['instruction'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'step_number': stepNumber,
      'instruction': instruction,
    };
  }

  @override
  String toString() =>
      'MealInstructionModel(id: $id, stepNumber: $stepNumber, '
      'instruction: $instruction)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealInstructionModel &&
        other.id == id &&
        other.stepNumber == stepNumber &&
        other.instruction == instruction;
  }

  @override
  int get hashCode => Object.hash(id, stepNumber, instruction);
}

class MealModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final double estimatedCost;
  final int cookingTime;
  final String difficulty;
  final int servings;
  final int? calories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MealIngredientModel> ingredients;
  final List<MealInstructionModel> instructions;

  const MealModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.estimatedCost,
    required this.cookingTime,
    required this.difficulty,
    required this.servings,
    this.calories,
    required this.createdAt,
    required this.updatedAt,
    required this.ingredients,
    required this.instructions,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      estimatedCost: _parseDecimal(json['estimated_cost']),
      cookingTime: json['cooking_time'] as int,
      difficulty: json['difficulty'] as String,
      servings: json['servings'] as int,
      calories: json['calories'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => MealIngredientModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      instructions: (json['instructions'] as List<dynamic>)
          .map((e) => MealInstructionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _parseDecimal(dynamic value) {
    if (value is String) return double.parse(value);
    if (value is num) return value.toDouble();
    throw FormatException('Unexpected numeric type: ${value.runtimeType}');
  }
  

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'estimated_cost': estimatedCost,
      'cooking_time': cookingTime,
      'difficulty': difficulty,
      'servings': servings,
      'calories': calories,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions.map((i) => i.toJson()).toList(),
    };
  }

  /// Trims trailing zeros for display (e.g. `500` instead of `500.0`).
  String get displayCost {
    if (estimatedCost == estimatedCost.roundToDouble()) {
      return estimatedCost.toInt().toString();
    }
    return estimatedCost.toString();
  }

  @override
  String toString() =>
      'MealModel(id: $id, name: $name, cookingTime: $cookingTime, '
      'difficulty: $difficulty, servings: $servings)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.estimatedCost == estimatedCost &&
        other.cookingTime == cookingTime &&
        other.difficulty == difficulty &&
        other.servings == servings &&
        other.calories == calories &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        imageUrl,
        estimatedCost,
        cookingTime,
        difficulty,
        servings,
        calories,
      );
}