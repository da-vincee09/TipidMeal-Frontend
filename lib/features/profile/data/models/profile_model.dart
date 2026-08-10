import 'package:meal_recommendation_app/features/profile/data/models/disliked_ingredient_model.dart';
import 'package:meal_recommendation_app/features/profile/data/models/food_allergy_model.dart';

class ProfileModel {
  final String id;
  final String authId;
  final String? profileImageUrl;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String sex;
  final double dailyBudget;
  final String cookingSkillLevel;
  final List<FoodAllergyModel> foodAllergies;
  final List<DislikedIngredientModel> dislikedIngredients;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.authId,
    this.profileImageUrl,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.sex,
    required this.dailyBudget,
    required this.cookingSkillLevel,
    required this.foodAllergies,
    required this.dislikedIngredients,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Builds a [ProfileModel] from the JSON object returned by FastAPI.
  ///
  /// Handles the nested `food_allergies` / `disliked_ingredients` lists by
  /// delegating to their own `fromJson` factories.
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      authId: json['auth_id'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      sex: json['sex'] as String,
      // dailyBudget may come back as an int or a double depending on how
      // the backend serializes it, so we parse defensively.
      dailyBudget: (json['daily_budget'] as num).toDouble(),
      cookingSkillLevel: json['cooking_skill_level'] as String,
      foodAllergies: (json['food_allergies'] as List<dynamic>? ?? [])
          .map((e) => FoodAllergyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      dislikedIngredients:
          (json['disliked_ingredients'] as List<dynamic>? ?? [])
              .map((e) =>
                  DislikedIngredientModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this model back into a JSON-compatible map.
  ///
  /// You generally won't send a full [ProfileModel] back to the server
  /// (use [ProfileCreateRequest]/[ProfileUpdateRequest] instead), but this
  /// is useful for local caching/debugging.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_id': authId,
      'profile_image_url': profileImageUrl,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'sex': sex,
      'daily_budget': dailyBudget,
      'cooking_skill_level': cookingSkillLevel,
      'food_allergies': foodAllergies.map((e) => e.toJson()).toList(),
      'disliked_ingredients':
          dislikedIngredients.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? authId,
    String? profileImageUrl,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? sex,
    double? dailyBudget,
    String? cookingSkillLevel,
    List<FoodAllergyModel>? foodAllergies,
    List<DislikedIngredientModel>? dislikedIngredients,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      cookingSkillLevel: cookingSkillLevel ?? this.cookingSkillLevel,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convenience getter for displaying the user's full name.
  String get fullName => '$firstName $lastName';

  @override
  String toString() =>
      'ProfileModel(id: $id, name: $fullName, sex: $sex, '
      'dailyBudget: $dailyBudget, cookingSkillLevel: $cookingSkillLevel)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileModel &&
        other.id == id &&
        other.authId == authId &&
        other.profileImageUrl == profileImageUrl &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.dateOfBirth == dateOfBirth &&
        other.sex == sex &&
        other.dailyBudget == dailyBudget &&
        other.cookingSkillLevel == cookingSkillLevel &&
        _listEquals(other.foodAllergies, foodAllergies) &&
        _listEquals(other.dislikedIngredients, dislikedIngredients) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        authId,
        profileImageUrl,
        firstName,
        lastName,
        dateOfBirth,
        sex,
        dailyBudget,
        cookingSkillLevel,
        Object.hashAll(foodAllergies),
        Object.hashAll(dislikedIngredients),
        createdAt,
        updatedAt,
      );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}