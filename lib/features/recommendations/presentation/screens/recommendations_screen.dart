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
    final sortBy = ref.watch(recommendationControllerProvider.notifier).sortBy;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recommendations',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          state.when(
            loading: () => const _LoadingState(),
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
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

          // Floating sort toggle, pinned to the bottom regardless of scroll.
          if (!state.isLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: _FloatingSortToggle(
                  sortBy: sortBy,
                  onChanged: (value) => ref
                      .read(recommendationControllerProvider.notifier)
                      .setSortBy(value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FloatingSortToggle extends StatelessWidget {
  final String sortBy;
  final ValueChanged<String> onChanged;

  const _FloatingSortToggle({
    required this.sortBy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInputBackground : Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pillOption(
            label: 'Best Match',
            value: 'score',
            selected: sortBy == 'score',
          ),
          _pillOption(
            label: 'Lowest Cost',
            value: 'cost',
            selected: sortBy == 'cost',
          ),
        ],
      ),
    );
  }

  Widget _pillOption({
    required String label,
    required String value,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.burntOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : null,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatefulWidget {
  const _LoadingState();

  @override
  State<_LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<_LoadingState>
    with SingleTickerProviderStateMixin {
  // One controller drives both the shimmer sweep and the cycling dots.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final dotCount = (t * 4).floor().clamp(0, 3);

        return Stack(
          children: [
            IgnorePointer(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: 6,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _SkeletonCard(t: t),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInputBackground : Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.4 : 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.burntOrange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: 'LOADING RECOMMENDATIONS'),
                            TextSpan(text: '.' * dotCount),
                            // Invisible dots keep the pill width constant.
                            TextSpan(
                              text: '.' * (3 - dotCount),
                              style: const TextStyle(color: Colors.transparent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double t;

  const _SkeletonCard({required this.t});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInputBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _Bone(t: t, width: 84, height: 84, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: _Bone(t: t, height: 16),
                ),
                const SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: _Bone(t: t, height: 12),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: _Bone(t: t, height: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Bone(t: t, width: 56, height: 22, radius: 100),
                    const SizedBox(width: 8),
                    _Bone(t: t, width: 56, height: 22, radius: 100),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double t;
  final double? width;
  final double height;
  final double radius;

  const _Bone({
    required this.t,
    this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.02);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlideGradient(-1 + 2 * t),
        ),
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double slidePercent;

  const _SlideGradient(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
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