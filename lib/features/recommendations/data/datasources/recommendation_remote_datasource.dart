import 'package:dio/dio.dart';
import 'package:meal_recommendation_app/core/errors/api_exception.dart';
import 'package:meal_recommendation_app/core/networks/api_constants.dart';
import 'package:meal_recommendation_app/features/recommendations/data/models/recommendation_model.dart';

abstract class RecommendationsRemoteDatasource {
  Future<List<RecommendationModel>> getRecommendations();
}

class RecommendationsRemoteDatasourceImpl
    implements RecommendationsRemoteDatasource {
  final Dio _dio;

  // ignore: prefer_initializing_formals
  RecommendationsRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<RecommendationModel>> getRecommendations() async {
    try {
      final response = await _dio.get(ApiConstants.recommendations);
      final recsJson = response.data['recommendations'] as List<dynamic>;
      return recsJson
          .map((e) => RecommendationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
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