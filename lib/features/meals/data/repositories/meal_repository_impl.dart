import 'package:meal_recommendation_app/features/meals/data/datasources/meals_remote_datasource.dart';
import 'package:meal_recommendation_app/features/meals/data/models/meal_model.dart';
import 'package:meal_recommendation_app/features/meals/domain/repository/meal_repository.dart';


class MealRepositoryImpl implements MealRepository {
  final MealsRemoteDatasource datasource;

  MealRepositoryImpl({required this.datasource});

  @override
  Future<List<MealModel>> getMeals() {
    return datasource.getMeals();
  }

  @override
  Future<MealModel> getMeal(String id) {
    return datasource.getMeal(id);
  }
}