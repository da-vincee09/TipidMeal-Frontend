class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.254.100:8000/api/v1';  

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

  static const String favorites = '/favorites';
  static String favoriteDetail(String mealId) => '/favorites/$mealId';
}