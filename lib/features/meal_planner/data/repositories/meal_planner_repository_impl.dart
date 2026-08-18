import 'package:meal_recommendation_app/features/meal_planner/data/datasources/meal_planner_remote_datasource.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_model.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_request.dart';
import 'package:meal_recommendation_app/features/meal_planner/domain/repositories/meal_planner_repository.dart';

class MealPlannerRepositoryImpl implements MealPlannerRepository {
  final MealPlannerRemoteDatasource datasource;

  MealPlannerRepositoryImpl({required this.datasource});

  @override
  Future<MealPlanEntryModel> createMealPlanEntry(MealPlanEntryCreateRequest request) {
    return datasource.createMealPlanEntry(request);
  }

  @override
  Future<WeeklyPlanModel> getMealPlan({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return datasource.getMealPlan(startDate: startDate, endDate: endDate);
  }

  @override
  Future<MealPlanEntryModel> getMealPlanEntry(String id) {
    return datasource.getMealPlanEntry(id);
  }

  @override
  Future<MealPlanEntryModel> updateMealPlanEntry(String id, MealPlanEntryUpdateRequest request) {
    return datasource.updateMealPlanEntry(id, request);
  }

  @override
  Future<void> deleteMealPlanEntry(String id) {
    return datasource.deleteMealPlanEntry(id);
  }
}