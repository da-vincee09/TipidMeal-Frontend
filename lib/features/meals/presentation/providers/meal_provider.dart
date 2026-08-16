import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meal_recommendation_app/features/meals/data/meal_dependencies.dart';
import 'package:meal_recommendation_app/features/meals/data/models/meal_model.dart';

final mealControllerProvider =
    NotifierProvider<MealController, AsyncValue<List<MealModel>>>(
  MealController.new,
);

class MealController extends Notifier<AsyncValue<List<MealModel>>> {
  @override
  AsyncValue<List<MealModel>> build() {
    // Idle until loadMeals() is explicitly called (e.g. when the Meals
    // screen mounts), mirroring PantryController's pattern.
    return const AsyncData([]);
  }

  Future<void> loadMeals() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(mealRepositoryProvider);
      final meals = await repository.getMeals();
      state = AsyncData(meals);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Fetches a single meal by id, used by the detail screen.
/// Kept separate from MealController since detail is a one-off read,
/// not part of the list state that needs mutation.
final mealDetailProvider =
    FutureProvider.family<MealModel, String>((ref, id) async {
  final repository = ref.read(mealRepositoryProvider);
  return repository.getMeal(id);
});

/// Current search text, entered by the user on the Meals screen.
final mealSearchQueryProvider = StateProvider<String>((ref) => '');

/// mealControllerProvider's data filtered by mealSearchQueryProvider.
/// Matches against meal name and ingredient names, since "what can I
/// make with chicken" is a more natural recipe-book query than an
/// exact-title search.
final filteredMealsProvider = Provider<List<MealModel>>((ref) {
  final query = ref.watch(mealSearchQueryProvider).toLowerCase().trim();
  final mealsState = ref.watch(mealControllerProvider);

  final meals = mealsState.value ?? [];
  if (query.isEmpty) return meals;

  return meals.where((meal) {
    final nameMatch = meal.name.toLowerCase().contains(query);
    final ingredientMatch = meal.ingredients
        .any((i) => i.ingredient.toLowerCase().contains(query));
    return nameMatch || ingredientMatch;
  }).toList();
});