class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.254.101:8000/api/v1'; 

  static const String profiles = '/profiles';
  static const String profileMe = '/profiles/me';

  static const String pantry = '/pantry';
  static const String meals = '/meals';
  static String mealDetail(String id) => '/meals/$id';

  static const String recommendations = '/recommendations';
}