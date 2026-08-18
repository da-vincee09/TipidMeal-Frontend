class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://tipidmeal-backend.onrender.com/api/v1';  

  static const String profiles = '/profiles';
  static const String profileMe = '/profiles/me';

  static const String pantry = '/pantry';

  static const String meals = '/meals';
  static String mealDetail(String id) => '/meals/$id';
  static String get mealUnits => '${ApiConstants.meals}/units';

  static const String recommendations = '/recommendations';

  static const String mealPlanner = '/meal-planner';
  static String mealPlanEntryDetail(String id) => '/meal-planner/$id';

  static const String groceryList = '/grocery-list';
}