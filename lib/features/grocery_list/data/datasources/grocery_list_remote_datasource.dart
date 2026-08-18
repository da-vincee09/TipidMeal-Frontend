import 'package:dio/dio.dart';
import 'package:meal_recommendation_app/core/errors/api_exception.dart';
import 'package:meal_recommendation_app/core/networks/api_constants.dart';
import 'package:meal_recommendation_app/features/grocery_list/data/models/grocery_list_model.dart';

abstract class GroceryListRemoteDatasource {
  Future<GroceryListResponseModel> getGroceryList({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class GroceryListRemoteDatasourceImpl implements GroceryListRemoteDatasource {
  final Dio _dio;

  // ignore: prefer_initializing_formals
  GroceryListRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<GroceryListResponseModel> getGroceryList({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.groceryList,
        queryParameters: {
          if (startDate != null) 'start_date': _formatDate(startDate),
          if (endDate != null) 'end_date': _formatDate(endDate),
        },
      );
      return GroceryListResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
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
      case 404:
        // "Profile not found" — same shared-404 limitation noted in
        // meal_planner_remote_datasource.dart.
        return const ServerException();
      case 400:
        // Backend raises 400 with a plain string detail when
        // start_date > end_date. Not a Pydantic validation list, so it
        // doesn't fit ValidationException's shape — falls through to
        // ServerException for now.
        return const ServerException();
      case 422:
        final errors = e.response?.data?['detail'] as List<dynamic>? ?? [];
        return ValidationException(errors);
      default:
        return const ServerException();
    }
  }
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}