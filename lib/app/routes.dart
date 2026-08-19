abstract final class AppRoutes {
  static const splash = "/";
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const profileSetup = '/profile-setup';
  static const profile = '/profile';
  static const pantry = '/pantry';
  static const meals = '/meals';
  static const recommendations = '/recommendations';
  static const mealPlanner = '/meal-planner';
  static const groceryList =  '/grocery-list';
  static const favorites = '/favorites';
  static String mealDetail(String id) => '/meal-detail/$id';
  static const settings = '/settings';
}