import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/core/networks/network_providers.dart';
import 'package:meal_recommendation_app/features/meals/data/datasources/meals_remote_datasource.dart';
import 'package:meal_recommendation_app/features/meals/data/repositories/meal_repository_impl.dart';
import 'package:meal_recommendation_app/features/meals/domain/repository/meal_repository.dart';


final mealsRemoteDatasourceProvider = Provider<MealsRemoteDatasource>((ref) {
  return MealsRemoteDatasourceImpl(
    dio: ref.watch(dioProvider),
  );
});

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepositoryImpl(
    datasource: ref.watch(mealsRemoteDatasourceProvider),
  );
});