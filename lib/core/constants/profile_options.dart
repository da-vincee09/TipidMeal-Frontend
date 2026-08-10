/// Predefined selectable options used by the profile form.
/// Centralized here so both ProfileSetupScreen and ProfileScreen's edit
/// mode (which share profile_form.dart) stay in sync automatically.
class ProfileOptions {
  ProfileOptions._();

  static const List<String> sexOptions = [
    'Male',
    'Female',
    'Prefer not to say',
  ];

  static const List<String> cookingSkillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  // Common allergens. Extend this list as needed — it's just a checklist,
  // not tied to any backend enum (the API accepts any list[str]).
  static const List<String> foodAllergies = [
    'Peanuts',
    'Tree Nuts',
    'Shellfish',
    'Shrimp',
    'Fish',
    'Eggs',
    'Milk/Dairy',
    'Soy',
    'Wheat/Gluten',
    'Sesame',
  ];

  // Common disliked ingredients in Filipino cooking. Extend as needed.
  static const List<String> dislikedIngredients = [
    'Cilantro',
    'Bitter Melon (Ampalaya)',
    'Okra',
    'Mushroom',
    'Onion',
    'Garlic',
    'Bell Pepper',
    'Liver',
    'Tofu',
    'Eggplant',
  ];
}