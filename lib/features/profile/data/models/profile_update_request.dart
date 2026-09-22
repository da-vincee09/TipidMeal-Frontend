class ProfileUpdateRequest {
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? sex;
  final double? budgetPerMeal;
  final String? cookingSkillLevel;
  final String? physicalActivityLevel;
  final List<String>? foodAllergies;
  final List<String>? dislikedIngredients;
  final String? profileImageUrl;

  const ProfileUpdateRequest({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.sex,
    this.budgetPerMeal,
    this.cookingSkillLevel,
    this.physicalActivityLevel,
    this.foodAllergies,
    this.dislikedIngredients,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth!.toIso8601String().split('T').first,
      if (sex != null) 'sex': sex,
      if (budgetPerMeal != null) 'budget_per_meal': budgetPerMeal,
      if (cookingSkillLevel != null)
        'cooking_skill_level': cookingSkillLevel,
      if (physicalActivityLevel != null)
        'physical_activity_level': physicalActivityLevel,
      if (foodAllergies != null) 'food_allergies': foodAllergies,
      if (dislikedIngredients != null)
        'disliked_ingredients': dislikedIngredients,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
    };
  }

  ProfileUpdateRequest copyWith({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? sex,
    double? budgetPerMeal,
    String? cookingSkillLevel,
    String? physicalActivityLevel,
    List<String>? foodAllergies,
    List<String>? dislikedIngredients,
    String? profileImageUrl,
  }) {
    return ProfileUpdateRequest(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      budgetPerMeal: budgetPerMeal ?? this.budgetPerMeal,
      cookingSkillLevel: cookingSkillLevel ?? this.cookingSkillLevel,
      physicalActivityLevel: physicalActivityLevel ?? this.physicalActivityLevel,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  bool get isEmpty => toJson().isEmpty;

  @override
  String toString() => 'ProfileUpdateRequest(${toJson()})';
}