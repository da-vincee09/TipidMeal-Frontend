import 'package:dio/dio.dart';
import 'package:meal_recommendation_app/core/errors/api_exception.dart';
import 'package:meal_recommendation_app/core/networks/api_constants.dart';
import 'package:meal_recommendation_app/features/favorites/data/models/favorite_model.dart';

abstract class FavoritesRemoteDatasource {
  Future<FavoriteModel> addFavorite(String mealId);
  Future<List<FavoriteModel>> getFavorites();
  Future<void> removeFavorite(String mealId);
}

class FavoritesRemoteDatasourceImpl implements FavoritesRemoteDatasource {
  final Dio _dio;

  // ignore: prefer_initializing_formals
  FavoritesRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<FavoriteModel> addFavorite(String mealId) async {
    try {
      final response = await _dio.post(
        ApiConstants.favorites,
        data: {'meal_id': mealId},
      );
      return FavoriteModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<FavoriteModel>> getFavorites() async {
    try {
      final response = await _dio.get(ApiConstants.favorites);
      final list = response.data as List<dynamic>;
      return list
          .map((e) => FavoriteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> removeFavorite(String mealId) async {
    try {
      await _dio.delete(ApiConstants.favoriteDetail(mealId));
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

    switch (e.response?.statusCode) {
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