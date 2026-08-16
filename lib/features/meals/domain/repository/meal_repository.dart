import 'package:meal_recommendation_app/features/meals/data/models/meal_model.dart';

abstract class MealRepository {
  Future<List<MealModel>> getMeals();
  Future<MealModel> getMeal(String id);
}