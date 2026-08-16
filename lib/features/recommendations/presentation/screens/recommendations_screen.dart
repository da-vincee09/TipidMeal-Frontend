import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/features/recommendations/presentation/providers/recommendation_provider.dart';
import 'package:meal_recommendation_app/features/recommendations/presentation/widgets/recommendation_card.dart';

class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recommendationControllerProvider.notifier).loadRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recommendations',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.burntOrange),
        ),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref
              .read(recommendationControllerProvider.notifier)
              .loadRecommendations(),
        ),
        data: (recommendations) {
          if (recommendations.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            color: AppColors.burntOrange,
            onRefresh: () => ref
                .read(recommendationControllerProvider.notifier)
                .loadRecommendations(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: recommendations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                return RecommendationCard(
                  recommendation: recommendation,
                  onTap: () =>
                      context.push('/meals/${recommendation.meal.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: AppColors.burntOrange,
            ),
            const SizedBox(height: 16),
            Text('No recommendations yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Add more items to your pantry and we\'ll suggest meals you can make.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}