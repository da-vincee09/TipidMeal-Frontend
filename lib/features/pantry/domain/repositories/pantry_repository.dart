import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_create_request.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_model.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_update_request.dart';

abstract class PantryRepository {
  Future<PantryItemModel> createPantryItem(PantryItemCreateRequest request);
  Future<List<PantryItemModel>> getPantryItems();
  Future<PantryItemModel> getPantryItem(String id);
  Future<PantryItemModel> updatePantryItem(
    String id,
    PantryItemUpdateRequest request,
  );
  Future<void> deletePantryItem(String id);
}