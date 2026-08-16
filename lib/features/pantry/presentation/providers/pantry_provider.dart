import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_create_request.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_model.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_update_request.dart';
import 'package:meal_recommendation_app/features/pantry/data/pantry_dependencies.dart';
import 'package:meal_recommendation_app/features/recommendations/presentation/providers/recommendation_provider.dart';

final pantryControllerProvider =
    NotifierProvider<PantryController, AsyncValue<List<PantryItemModel>>>(
  PantryController.new,
);

class PantryController extends Notifier<AsyncValue<List<PantryItemModel>>> {
  @override
  AsyncValue<List<PantryItemModel>> build() {
    // Idle until loadItems() is explicitly called (e.g. when the Pantry
    // screen mounts), mirroring ProfileController's pattern.
    return const AsyncData([]);
  }

  Future<void> loadItems() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(pantryRepositoryProvider);
      final items = await repository.getPantryItems();
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> addItem(PantryItemCreateRequest request) async {
    final currentItems = state.value ?? [];

    try {
      final repository = ref.read(pantryRepositoryProvider);
      final newItem = await repository.createPantryItem(request);
      state = AsyncData([...currentItems, newItem]);

      // Recommendations depend on pantry contents — refresh them too,
      // so the tab shows fresh data without needing a manual pull or
      // a hot restart.
      ref.read(recommendationControllerProvider.notifier).loadRecommendations();

      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateItem(String id, PantryItemUpdateRequest request) async {
    final currentItems = state.value ?? [];

    try {
      final repository = ref.read(pantryRepositoryProvider);
      final updated = await repository.updatePantryItem(id, request);
      state = AsyncData([
        for (final item in currentItems)
          if (item.id == id) updated else item,
      ]);

      ref.read(recommendationControllerProvider.notifier).loadRecommendations();

      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    final currentItems = state.value ?? [];

    try {
      final repository = ref.read(pantryRepositoryProvider);
      await repository.deletePantryItem(id);
      state = AsyncData(
        currentItems.where((item) => item.id != id).toList(),
      );

      ref.read(recommendationControllerProvider.notifier).loadRecommendations();

      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}