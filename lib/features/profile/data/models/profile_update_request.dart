class ProfileUpdateRequest {
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? sex;
  final double? dailyBudget;
  final String? cookingSkillLevel;
  final List<String>? foodAllergies;
  final List<String>? dislikedIngredients;
  final String? profileImageUrl;

  const ProfileUpdateRequest({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.sex,
    this.dailyBudget,
    this.cookingSkillLevel,
    this.foodAllergies,
    this.dislikedIngredients,
    this.profileImageUrl,
  });

  /// Converts this request into the JSON body FastAPI expects, omitting
  /// any field that wasn't changed (i.e. is still null).
  Map<String, dynamic> toJson() {
    return {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth!.toIso8601String().split('T').first,
      if (sex != null) 'sex': sex,
      if (dailyBudget != null) 'daily_budget': dailyBudget,
      if (cookingSkillLevel != null)
        'cooking_skill_level': cookingSkillLevel,
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
    double? dailyBudget,
    String? cookingSkillLevel,
    List<String>? foodAllergies,
    List<String>? dislikedIngredients,
    String? profileImageUrl,
  }) {
    return ProfileUpdateRequest(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      cookingSkillLevel: cookingSkillLevel ?? this.cookingSkillLevel,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  /// True if no fields have been set — useful to short-circuit an update
  /// call and avoid sending an empty PUT request.
  bool get isEmpty => toJson().isEmpty;

  @override
  String toString() => 'ProfileUpdateRequest(${toJson()})';
}