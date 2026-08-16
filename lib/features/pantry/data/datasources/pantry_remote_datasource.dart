import 'package:dio/dio.dart';
import 'package:meal_recommendation_app/core/errors/api_exception.dart';
import 'package:meal_recommendation_app/core/networks/api_constants.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_create_request.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_model.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_update_request.dart';

abstract class PantryRemoteDatasource {
  Future<PantryItemModel> createPantryItem(PantryItemCreateRequest request);
  Future<List<PantryItemModel>> getPantryItems();
  Future<PantryItemModel> getPantryItem(String id);
  Future<PantryItemModel> updatePantryItem(
    String id,
    PantryItemUpdateRequest request,
  );
  Future<void> deletePantryItem(String id);
}

class PantryRemoteDatasourceImpl implements PantryRemoteDatasource {
  final Dio _dio;

  // ignore: prefer_initializing_formals
  PantryRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<PantryItemModel> createPantryItem(
    PantryItemCreateRequest request,
  ) async {
    final json = await _request<Map<String, dynamic>>(
      () => _dio.post(ApiConstants.pantry, data: request.toJson()),
    );
    return PantryItemModel.fromJson(json);
  }

  @override
  Future<List<PantryItemModel>> getPantryItems() async {
    final list = await _request<List<dynamic>>(
      () => _dio.get(ApiConstants.pantry),
    );
    return list
        .map((e) => PantryItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PantryItemModel> getPantryItem(String id) async {
    final json = await _request<Map<String, dynamic>>(
      () => _dio.get('${ApiConstants.pantry}/$id'),
    );
    return PantryItemModel.fromJson(json);
  }

  @override
  Future<PantryItemModel> updatePantryItem(
    String id,
    PantryItemUpdateRequest request,
  ) async {
    final json = await _request<Map<String, dynamic>>(
      () => _dio.put('${ApiConstants.pantry}/$id', data: request.toJson()),
    );
    return PantryItemModel.fromJson(json);
  }

  @override
  Future<void> deletePantryItem(String id) async {
    try {
      await _dio.delete('${ApiConstants.pantry}/$id');
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<T> _request<T>(Future<Response> Function() call) async {
    try {
      final response = await call();
      return response.data as T;
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

    final response = e.response!;
    final body = response.data;
    final detail = body is Map<String, dynamic> ? body['detail'] : null;

    switch (response.statusCode) {
      case 401:
        return UnauthorizedException(
          detail is String ? detail : const UnauthorizedException().message,
        );
      case 404:
        return PantryItemNotFoundException(
          detail is String
              ? detail
              : const PantryItemNotFoundException().message,
        );
      case 422:
        return ValidationException(detail is List ? detail : const []);
      default:
        final message = body is Map<String, dynamic> ? body['message'] : null;
        return ServerException(
          message is String ? message : const ServerException().message,
        );
    }
  }
}