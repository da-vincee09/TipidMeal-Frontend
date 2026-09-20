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
    'beginner',
    'intermediate',
    'advanced',
  ];

  static String skillLabel(String value) {
    if (value.isEmpty) return value;
    final lower = value.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

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

  // API values (match the backend enum). Display labels come from
  // activityLabel() so the UI can say "Moderately Active" while the
  // request sends "moderately_active".
  static const List<String> physicalActivityLevels = [
    'sedentary',
    'moderately_active',
    'active',
  ];

  static const Map<String, String> _activityLabels = {
    'sedentary': 'Sedentary',
    'moderately_active': 'Moderately Active',
    'active': 'Active',
  };

  // Generic hints. Swap in the PDRI wording from your thesis if you want
  // these to match it exactly.
  static const Map<String, String> _activityHints = {
    'sedentary': 'Mostly sitting, little to no exercise.',
    'moderately_active': 'Light exercise or activity a few days a week.',
    'active': 'Regular exercise or a physically demanding daily routine.',
  };

  static String activityLabel(String value) => _activityLabels[value] ?? value;

  static String? activityHint(String? value) =>
      value == null ? null : _activityHints[value];
}