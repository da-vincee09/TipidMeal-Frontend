import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/core/networks/api_constants.dart';
import 'package:meal_recommendation_app/core/networks/network_providers.dart';
import 'package:meal_recommendation_app/features/pantry/data/datasources/pantry_remote_datasource.dart';
import 'package:meal_recommendation_app/features/pantry/data/repositories/pantry_repository_impl.dart';
import 'package:meal_recommendation_app/features/pantry/domain/repositories/pantry_repository.dart';
import 'package:meal_recommendation_app/features/pantry/data/datasources/ingredient_suggestion_remote_datasource.dart';

final pantryRemoteDatasourceProvider = Provider<PantryRemoteDatasource>((ref) {
  return PantryRemoteDatasourceImpl(
    dio: ref.watch(dioProvider),
  );
});

final pantryRepositoryProvider = Provider<PantryRepository>((ref) {
  return PantryRepositoryImpl(
    datasource: ref.watch(pantryRemoteDatasourceProvider),
  );
});

final ingredientSuggestionDatasourceProvider =
    Provider<IngredientSuggestionRemoteDatasource>((ref) {
  return IngredientSuggestionRemoteDatasourceImpl(
    dio: ref.watch(dioProvider),
  );
});

final allUnitsProvider = FutureProvider<List<String>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(ApiConstants.mealUnits);
    return (response.data as List<dynamic>).cast<String>();
  } catch (_) {
    // Network hiccup on a non-critical lookup — fall back to a small
    // hardcoded set rather than blocking pantry entry entirely.
    return const ['g', 'kg', 'ml', 'l', 'pcs', 'cup', 'tbsp', 'tsp'];
  }
});