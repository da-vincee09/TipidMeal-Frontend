class FoodAllergyModel {
  final String id;
  final String allergy;

  const FoodAllergyModel({
    required this.id, 
    required this.allergy
  });

  factory FoodAllergyModel.fromJson(Map<String, dynamic> json) {
    return FoodAllergyModel(
      id: json['id'] as String, 
      allergy: json['allergy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'allergy': allergy,
    };
  }

  FoodAllergyModel copyWith({
    String? id,
    String? allergy,
  }) {
    return FoodAllergyModel(
      id: id ?? this.id, 
      allergy: allergy ?? this.allergy,
    );
  }

  @override
  String toString() => 'FoodAllergyModel(id: $id, allergy: $allergy)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodAllergyModel &&
    other.id == id &&
    other.allergy == allergy;
  }

  @override
  int get hashCode => Object.hash(id, allergy);
}