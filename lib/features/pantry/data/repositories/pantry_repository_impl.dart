import 'package:meal_recommendation_app/features/pantry/data/datasources/pantry_remote_datasource.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_create_request.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_model.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_update_request.dart';
import 'package:meal_recommendation_app/features/pantry/domain/repositories/pantry_repository.dart';

class PantryRepositoryImpl implements PantryRepository {
  final PantryRemoteDatasource datasource;

  PantryRepositoryImpl({required this.datasource});

  @override
  Future<PantryItemModel> createPantryItem(PantryItemCreateRequest request) {
    return datasource.createPantryItem(request);
  }

  @override
  Future<List<PantryItemModel>> getPantryItems() {
    return datasource.getPantryItems();
  }

  @override
  Future<PantryItemModel> getPantryItem(String id) {
    return datasource.getPantryItem(id);
  }

  @override
  Future<PantryItemModel> updatePantryItem(
    String id,
    PantryItemUpdateRequest request,
  ) {
    return datasource.updatePantryItem(id, request);
  }

  @override
  Future<void> deletePantryItem(String id) {
    return datasource.deletePantryItem(id);
  }
}