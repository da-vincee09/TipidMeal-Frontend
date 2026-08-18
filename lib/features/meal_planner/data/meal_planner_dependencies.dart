import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/core/networks/network_providers.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/datasources/meal_planner_remote_datasource.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/repositories/meal_planner_repository_impl.dart';
import 'package:meal_recommendation_app/features/meal_planner/domain/repositories/meal_planner_repository.dart';

final mealPlannerRemoteDatasourceProvider = Provider<MealPlannerRemoteDatasource>((ref) {
  return MealPlannerRemoteDatasourceImpl(
    dio: ref.watch(dioProvider),
  );
});

final mealPlannerRepositoryProvider = Provider<MealPlannerRepository>((ref) {
  return MealPlannerRepositoryImpl(
    datasource: ref.watch(mealPlannerRemoteDatasourceProvider),
  );
});