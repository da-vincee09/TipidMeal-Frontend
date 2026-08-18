import 'package:meal_recommendation_app/features/grocery_list/data/datasources/grocery_list_remote_datasource.dart';
import 'package:meal_recommendation_app/features/grocery_list/data/models/grocery_list_model.dart';
import 'package:meal_recommendation_app/features/grocery_list/domain/repositories/grocery_list_repository.dart';

class GroceryListRepositoryImpl implements GroceryListRepository {
  final GroceryListRemoteDatasource datasource;

  GroceryListRepositoryImpl({required this.datasource});

  @override
  Future<GroceryListResponseModel> getGroceryList({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return datasource.getGroceryList(startDate: startDate, endDate: endDate);
  }
}