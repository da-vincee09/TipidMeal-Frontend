import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/core/networks/network_providers.dart';
import 'package:meal_recommendation_app/features/grocery_list/data/datasources/grocery_list_remote_datasource.dart';
import 'package:meal_recommendation_app/features/grocery_list/data/repositories/grocery_list_repository_impl.dart';
import 'package:meal_recommendation_app/features/grocery_list/domain/repositories/grocery_list_repository.dart';

final groceryListRemoteDatasourceProvider =
    Provider<GroceryListRemoteDatasource>((ref) {
  return GroceryListRemoteDatasourceImpl(
    dio: ref.watch(dioProvider),
  );
});

final groceryListRepositoryProvider = Provider<GroceryListRepository>((ref) {
  return GroceryListRepositoryImpl(
    datasource: ref.watch(groceryListRemoteDatasourceProvider),
  );
});