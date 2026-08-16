import 'package:dio/dio.dart';
import 'package:meal_recommendation_app/core/errors/api_exception.dart';
import 'package:meal_recommendation_app/core/networks/api_constants.dart';
import 'package:meal_recommendation_app/features/meals/data/models/meal_model.dart';

abstract class MealsRemoteDatasource {
  Future<List<MealModel>> getMeals();
  Future<MealModel> getMeal(String id);   
}

class MealsRemoteDatasourceImpl implements MealsRemoteDatasource {
  final Dio _dio;

  // ignore: prefer_initializing_formals
  MealsRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<MealModel>> getMeals() async {
    try {
      final response = await _dio.get(ApiConstants.meals);
      final mealsJson = response.data['meals'] as List<dynamic>;
      return mealsJson
          .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<MealModel> getMeal(String id) async {
    try {
      final response = await _dio.get(ApiConstants.mealDetail(id));
      return MealModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw MealNotFoundException();
      }
      throw _mapDioException(e);
    }
  }

  ApiException _mapDioException(DioException e) {
    final isConnectivityIssue = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        true,
      _ => false,
    };

    if (isConnectivityIssue || e.response == null) {
      return const NetworkException();
    }

    final statusCode = e.response?.statusCode;

    switch (statusCode) {
      case 401:
        return const UnauthorizedException();
      case 422:
        final errors = e.response?.data?['detail'] as List<dynamic>? ?? [];
        return ValidationException(errors);
      default:
        return const ServerException();
    }
  }
}