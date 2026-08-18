import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/features/grocery_list/data/grocery_list_dependencies.dart';
import 'package:meal_recommendation_app/features/grocery_list/data/models/grocery_list_model.dart';

final groceryListControllerProvider = NotifierProvider<GroceryListController,
    AsyncValue<GroceryListResponseModel?>>(
  GroceryListController.new,
);

class GroceryListController
    extends Notifier<AsyncValue<GroceryListResponseModel?>> {
  @override
  AsyncValue<GroceryListResponseModel?> build() {
    return const AsyncData(null);
  }

  /// [startDate]/[endDate] are optional — if both are omitted, the
  /// backend defaults to the current Monday–Sunday week.
  Future<void> loadGroceryList({DateTime? startDate, DateTime? endDate}) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(groceryListRepositoryProvider);
      final list = await repository.getGroceryList(
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncData(list);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}