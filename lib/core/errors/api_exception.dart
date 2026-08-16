sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Your session has expired. Please log in again.',
  ]);
}

class ProfileNotFoundException extends ApiException {
  const ProfileNotFoundException([super.message = 'Profile not found']);
}

class PantryItemNotFoundException extends ApiException {
  const PantryItemNotFoundException([
    super.message = 'Pantry item not found',
  ]);
}

class MealNotFoundException extends ApiException {
  MealNotFoundException() : super('Meal not found');
}

class ValidationException extends ApiException {
  final List<dynamic> errors;
  const ValidationException(this.errors, [super.message = 'Invalid data']);
}

class ServerException extends ApiException {
  const ServerException([
    super.message = 'Something went wrong on our end. Please try again.',
  ]);
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Could not reach the server. Check your connection.',
  ]);
}