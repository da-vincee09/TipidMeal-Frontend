import 'package:dio/dio.dart';
import 'package:meal_recommendation_app/core/errors/api_exception.dart';
import 'package:meal_recommendation_app/core/networks/api_constants.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/ingredient_suggestion_model.dart';

abstract class IngredientSuggestionRemoteDatasource {
  Future<List<IngredientSuggestionModel>> search(String query);
}

class IngredientSuggestionRemoteDatasourceImpl
    implements IngredientSuggestionRemoteDatasource {
  final Dio _dio;

  // ignore: prefer_initializing_formals
  IngredientSuggestionRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<IngredientSuggestionModel>> search(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        '${ApiConstants.meals}/ingredients/suggestions',
        queryParameters: {'search': query.trim()},
      );
      return (response.data as List<dynamic>)
          .map((e) =>
              IngredientSuggestionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Suggestions are non-critical — fail quietly to an empty list rather
      // than blocking the user from typing their own ingredient.
      if (e.type == DioExceptionType.connectionError) {
        return [];
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

    return const ServerException();
  }
}