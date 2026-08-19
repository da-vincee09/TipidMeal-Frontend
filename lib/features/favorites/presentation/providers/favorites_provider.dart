import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/features/favorites/data/favorites_dependencies.dart';
import 'package:meal_recommendation_app/features/favorites/domain/entities/favorite.dart';

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, AsyncValue<List<Favorite>>>(
  FavoritesController.new,
);

class FavoritesController extends Notifier<AsyncValue<List<Favorite>>> {
  @override
  AsyncValue<List<Favorite>> build() => const AsyncData([]);

  Future<void> loadFavorites() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(favoritesRepositoryProvider);
      final favorites = await repository.getFavorites();
      state = AsyncData(favorites);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  bool isFavorite(String mealId) {
    return state.value?.any((f) => f.meal.id == mealId) ?? false;
  }

  /// Optimistically adds [mealId] to the favorites list using the
  /// meal's already-known display fields, then confirms with the
  /// server. Rolls back if the request fails.
  Future<void> addFavorite({
    required String mealId,
    required String mealName,
    required double estimatedCost,
    String? imageUrl,
  }) async {
    final previousState = state;
    final current = state.value ?? [];

    if (current.any((f) => f.meal.id == mealId)) return;

    final optimisticEntry = Favorite(
      id: 'optimistic-$mealId',
      meal: FavoriteMealSummary(
        id: mealId,
        name: mealName,
        estimatedCost: estimatedCost,
        imageUrl: imageUrl,
      ),
      createdAt: DateTime.now(),
    );

    state = AsyncData([optimisticEntry, ...current]);

    try {
      final repository = ref.read(favoritesRepositoryProvider);
      final confirmed = await repository.addFavorite(mealId);
      final updated = (state.value ?? [])
          .map((f) => f.id == optimisticEntry.id ? confirmed : f)
          .toList();
      state = AsyncData(updated);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> removeFavorite(String mealId) async {
    final previousState = state;
    final current = state.value ?? [];

    state = AsyncData(current.where((f) => f.meal.id != mealId).toList());

    try {
      final repository = ref.read(favoritesRepositoryProvider);
      await repository.removeFavorite(mealId);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}