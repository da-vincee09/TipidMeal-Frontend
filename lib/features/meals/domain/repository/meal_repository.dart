import 'package:meal_recommendation_app/features/meals/data/models/meal_model.dart';
import 'package:meal_recommendation_app/features/nutrition/data/models/nutrition_adequacy_model.dart';

abstract class MealRepository {
  Future<List<MealModel>> getMeals();
  Future<MealModel> getMeal(String id);
  Future<NutritionAdequacyModel> getNutritionAdequacy(String mealId);
}