import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_model.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_request.dart';

abstract class MealPlannerRepository {
  Future<MealPlanEntryModel> createMealPlanEntry(MealPlanEntryCreateRequest request);
  Future<WeeklyPlanModel> getMealPlan({required DateTime startDate, required DateTime endDate});
  Future<MealPlanEntryModel> getMealPlanEntry(String id);
  Future<MealPlanEntryModel> updateMealPlanEntry(String id, MealPlanEntryUpdateRequest request);
  Future<void> deleteMealPlanEntry(String id);
}