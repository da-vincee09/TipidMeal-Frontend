import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/meal_planner_dependencies.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_model.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_request.dart';

final mealPlanControllerProvider =
    NotifierProvider<MealPlanController, AsyncValue<WeeklyPlanModel?>>(
  MealPlanController.new,
);

class MealPlanController extends Notifier<AsyncValue<WeeklyPlanModel?>> {
  DateTime? _lastStartDate;
  DateTime? _lastEndDate;

  @override
  AsyncValue<WeeklyPlanModel?> build() {
    return const AsyncData(null);
  }

  /// Full load with a loading state — used on first mount and week
  /// navigation, where showing a spinner while the whole week's data
  /// changes is expected and not jarring.
  Future<void> loadWeek({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _lastStartDate = startDate;
    _lastEndDate = endDate;
    state = const AsyncLoading();
    try {
      final repository = ref.read(mealPlannerRepositoryProvider);
      final plan = await repository.getMealPlan(
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncData(plan);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Refetches the current week WITHOUT flashing a loading spinner —
  /// the existing data stays on screen until the new data is ready,
  /// then swaps in. Used after add/update, where we don't have enough
  /// info client-side to safely predict the server's response (slot
  /// ordering, recalculated totals, etc.).
  Future<void> _silentReloadCurrentWeek() async {
    if (_lastStartDate == null || _lastEndDate == null) return;
    try {
      final repository = ref.read(mealPlannerRepositoryProvider);
      final plan = await repository.getMealPlan(
        startDate: _lastStartDate!,
        endDate: _lastEndDate!,
      );
      state = AsyncData(plan);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addEntry(MealPlanEntryCreateRequest request) async {
    final repository = ref.read(mealPlannerRepositoryProvider);
    await repository.createMealPlanEntry(request);
    await _silentReloadCurrentWeek();
  }

  Future<void> updateEntry(String id, MealPlanEntryUpdateRequest request) async {
    final repository = ref.read(mealPlannerRepositoryProvider);
    await repository.updateMealPlanEntry(id, request);
    await _silentReloadCurrentWeek();
  }

  /// Removes the entry from the in-memory list immediately (so the
  /// card disappears the instant the user confirms), then deletes it
  /// on the server in the background. If the server call fails, the
  /// previous state is restored and the error is rethrown so the
  /// caller can show a message.
  Future<void> removeEntry(String id) async {
    final previousState = state;
    final currentPlan = state.value;

    if (currentPlan != null) {
      MealPlanEntryModel? removed;
      final remainingEntries = <MealPlanEntryModel>[];
      for (final entry in currentPlan.entries) {
        if (entry.id == id) {
          removed = entry;
        } else {
          remainingEntries.add(entry);
        }
      }

      final adjustedTotal = removed == null
          ? currentPlan.estimatedCostTotal
          : currentPlan.estimatedCostTotal - removed.meal.estimatedCost;

      state = AsyncData(
        WeeklyPlanModel(
          startDate: currentPlan.startDate,
          endDate: currentPlan.endDate,
          entries: remainingEntries,
          estimatedCostTotal: adjustedTotal,
        ),
      );
    }

    try {
      final repository = ref.read(mealPlannerRepositoryProvider);
      await repository.deleteMealPlanEntry(id);
    } catch (e) {
      // Roll back to the pre-delete state so the entry reappears.
      state = previousState;
      rethrow;
    }
  }
}