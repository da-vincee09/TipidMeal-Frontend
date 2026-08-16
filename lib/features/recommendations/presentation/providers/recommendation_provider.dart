import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/features/recommendations/data/models/recommendation_model.dart';
import 'package:meal_recommendation_app/features/recommendations/data/recommendation_dependencies.dart';

final recommendationControllerProvider = NotifierProvider<RecommendationController,
    AsyncValue<List<RecommendationModel>>>(
  RecommendationController.new,
);

class RecommendationController
    extends Notifier<AsyncValue<List<RecommendationModel>>> {
  @override
  AsyncValue<List<RecommendationModel>> build() {
    // Idle until loadRecommendations() is called, mirroring MealController.
    return const AsyncData([]);
  }

  Future<void> loadRecommendations() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(recommendationRepositoryProvider);
      final recommendations = await repository.getRecommendations();
      state = AsyncData(recommendations);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}