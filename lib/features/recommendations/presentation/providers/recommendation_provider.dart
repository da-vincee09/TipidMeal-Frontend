import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/features/recommendations/data/models/recommendation_model.dart';
import 'package:meal_recommendation_app/features/recommendations/data/recommendation_dependencies.dart';

final recommendationControllerProvider = NotifierProvider<RecommendationController,
    AsyncValue<List<RecommendationModel>>>(
  RecommendationController.new,
);

class RecommendationController
    extends Notifier<AsyncValue<List<RecommendationModel>>> {
  String _sortBy = 'score';
  List<RecommendationModel> _rawRecommendations = [];

  String get sortBy => _sortBy;

  @override
  AsyncValue<List<RecommendationModel>> build() {
    // Idle until loadRecommendations() is called, mirroring MealController.
    return const AsyncData([]);
  }

  /// Fetches from the network once. Sorting afterward is handled entirely
  /// client-side via [setSortBy] — no re-fetch, no race between requests.
  Future<void> loadRecommendations() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(recommendationRepositoryProvider);
      // Backend default order doesn't matter — we always re-sort locally
      // against whichever sortBy is currently active.
      final recommendations = await repository.getRecommendations();
      _rawRecommendations = recommendations;
      state = AsyncData(_sorted(_rawRecommendations, _sortBy));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Re-sorts the already-fetched list in memory. Synchronous, instant,
  /// no loading state — this is what makes toggling feel immediate and
  /// eliminates the stale-response race from the old fetch-per-tap design.
  void setSortBy(String sortBy) {
    if (_sortBy == sortBy) return;
    _sortBy = sortBy;
    state = AsyncData(_sorted(_rawRecommendations, _sortBy));
  }

  List<RecommendationModel> _sorted(
    List<RecommendationModel> recommendations,
    String sortBy,
  ) {
    final sorted = List<RecommendationModel>.from(recommendations);

    if (sortBy == 'cost') {
      // Ascending cost; hybrid score breaks ties — mirrors the backend's
      // sort_by=cost logic exactly.
      sorted.sort((a, b) {
        final costCompare =
            a.meal.estimatedCost.compareTo(b.meal.estimatedCost);
        if (costCompare != 0) return costCompare;
        return b.hybridScore.compareTo(a.hybridScore);
      });
    } else {
      // "score": tier good pantry match ("adapt") ahead of "fallback",
      // hybrid score breaks ties within each tier — mirrors the backend's
      // default sort_by=score logic exactly.
      sorted.sort((a, b) {
        final aFallback = a.adaptation.decision != 'adapt';
        final bFallback = b.adaptation.decision != 'adapt';
        if (aFallback != bFallback) {
          return aFallback ? 1 : -1;
        }
        return b.hybridScore.compareTo(a.hybridScore);
      });
    }

    return sorted;
  }
}