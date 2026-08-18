import 'package:meal_recommendation_app/features/grocery_list/data/models/grocery_list_model.dart';

abstract class GroceryListRepository {
  Future<GroceryListResponseModel> getGroceryList({
    DateTime? startDate,
    DateTime? endDate,
  });
}