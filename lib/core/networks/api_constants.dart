class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.254.101:8000/api/v1'; // add the prefix here
  // OR keep baseUrl bare and prefix these instead — pick one, not both:
  static const String profiles = '/profiles';
  static const String profileMe = '/profiles/me';
}