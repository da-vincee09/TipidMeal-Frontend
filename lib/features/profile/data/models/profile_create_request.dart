class ProfileCreateRequest {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String sex;
  final double dailyBudget;
  final String cookingSkillLevel;
  final List<String> foodAllergies;
  final List<String> dislikedIngredients;
  final String? profileImageUrl;

  const ProfileCreateRequest({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.sex,
    required this.dailyBudget,
    required this.cookingSkillLevel,
    this.foodAllergies = const [],
    this.dislikedIngredients = const [],
    this.profileImageUrl,
  });

  /// Converts this request into the JSON body FastAPI expects.
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      // Date-only string, e.g. "2002-05-15", matching the backend's
      // expected format for `date_of_birth`.
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'sex': sex,
      'daily_budget': dailyBudget,
      'cooking_skill_level': cookingSkillLevel,
      'food_allergies': foodAllergies,
      'disliked_ingredients': dislikedIngredients,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
    };
  }

  ProfileCreateRequest copyWith({
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
    return ProfileCreateRequest(
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

  @override
  String toString() =>
      'ProfileCreateRequest(firstName: $firstName, lastName: $lastName, '
      'sex: $sex, dailyBudget: $dailyBudget)';
}