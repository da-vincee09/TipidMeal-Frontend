import 'package:dio/dio.dart';
import 'package:meal_recommendation_app/core/errors/api_exception.dart';
import 'package:meal_recommendation_app/core/networks/api_constants.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_model.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_request.dart';

abstract class MealPlannerRemoteDatasource {
  Future<MealPlanEntryModel> createMealPlanEntry(MealPlanEntryCreateRequest request);
  Future<WeeklyPlanModel> getMealPlan({required DateTime startDate, required DateTime endDate});
  Future<MealPlanEntryModel> getMealPlanEntry(String id);
  Future<MealPlanEntryModel> updateMealPlanEntry(String id, MealPlanEntryUpdateRequest request);
  Future<void> deleteMealPlanEntry(String id);
}

class MealPlannerRemoteDatasourceImpl implements MealPlannerRemoteDatasource {
  final Dio _dio;

  // ignore: prefer_initializing_formals
  MealPlannerRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<MealPlanEntryModel> createMealPlanEntry(
    MealPlanEntryCreateRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.mealPlanner,
        data: request.toJson(),
      );
      return MealPlanEntryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<WeeklyPlanModel> getMealPlan({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.mealPlanner,
        queryParameters: {
          'start_date': _formatDate(startDate),
          'end_date': _formatDate(endDate),
        },
      );
      return WeeklyPlanModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<MealPlanEntryModel> getMealPlanEntry(String id) async {
    try {
      final response = await _dio.get(ApiConstants.mealPlanEntryDetail(id));
      return MealPlanEntryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<MealPlanEntryModel> updateMealPlanEntry(
    String id,
    MealPlanEntryUpdateRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.mealPlanEntryDetail(id),
        data: request.toJson(),
      );
      return MealPlanEntryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<void> deleteMealPlanEntry(String id) async {
    try {
      await _dio.delete(ApiConstants.mealPlanEntryDetail(id));
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
        // Backend raises a plain 404 for both "profile not found" and
        // "entry not found" — no dedicated exception type yet, unlike
        // MealNotFoundException in the meals feature. Falls through to
        // ServerException for now; add a MealPlanEntryNotFoundException
        // to api_exception.dart if the UI needs to distinguish this case.
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