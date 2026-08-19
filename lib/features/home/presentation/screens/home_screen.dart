// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/app/routes.dart';
import 'package:meal_recommendation_app/features/pantry/presentation/providers/pantry_provider.dart';
import 'package:meal_recommendation_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:meal_recommendation_app/features/recommendations/presentation/providers/recommendation_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Profile may already be loaded (e.g. from splash), but calling
      // this again is cheap and guarantees Home always has fresh data
      // rather than depending on load-order elsewhere in the app.
      ref.read(profileControllerProvider.notifier).loadProfile();
      ref.read(pantryControllerProvider.notifier).loadItems();
      ref.read(recommendationControllerProvider.notifier).loadRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileControllerProvider);
    final pantryState = ref.watch(pantryControllerProvider);
    final recommendationsState = ref.watch(recommendationControllerProvider);

    final profile = profileState.value;
    final pantryCount = pantryState.value?.length ?? 0;
    final topRecommendations = (recommendationsState.value ?? []).take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.burntOrange,
            appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.favorites),
            icon: const Icon(Icons.favorite_border_rounded),
            color: AppColors.cream,
            tooltip: 'Favorites',
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.profile),
            icon: const Icon(Icons.person_outline_rounded),
            color: AppColors.cream,
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(profileControllerProvider.notifier).loadProfile(),
              ref.read(pantryControllerProvider.notifier).loadItems(),
              ref
                  .read(recommendationControllerProvider.notifier)
                  .loadRecommendations(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                profile != null ? 'Hi, ${profile.firstName}!' : 'Welcome!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "What's cooking today?",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 24),

              // Budget + pantry count summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.payments_outlined,
                      label: 'Daily Budget',
                      value: profile != null
                          ? '₱${profile.dailyBudget.toStringAsFixed(0)}'
                          : '—',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.kitchen_outlined,
                      label: 'Pantry Items',
                      value: pantryState.isLoading ? '—' : '$pantryCount',
                      onTap: () => context.go(AppRoutes.pantry),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick actions — meal planner and grocery list, neither
              // of which has a path from Home otherwise.
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Meal Planner',
                      onTap: () => context.push('/meal-planner'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Grocery List',
                      onTap: () => context.push('/grocery-list'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Top recommendations preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended for you',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.cream,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.recommendations),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: AppColors.cream.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _RecommendationsPreview(
                state: recommendationsState,
                recommendations: topRecommendations,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.burntOrange),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.burntOrange,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.burntOrange.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.burntOrange, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.burntOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationsPreview extends StatelessWidget {
  final AsyncValue<List<dynamic>> state;
  final List<dynamic> recommendations;

  const _RecommendationsPreview({
    required this.state,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.cream),
        ),
      );
    }

    if (state.hasError) {
      return _PreviewMessage(
        icon: Icons.error_outline,
        text: "Couldn't load recommendations.",
      );
    }

    if (recommendations.isEmpty) {
      return _PreviewMessage(
        icon: Icons.lightbulb_outline,
        text: 'Add more pantry items to get meal suggestions.',
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final rec = recommendations[index];
          final meal = rec.meal;

          return GestureDetector(
            onTap: () => context.push('/meals/${meal.id}'),
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: meal.imageUrl != null
                        ? Image.network(
                            meal.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.burntOrange.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.restaurant_menu_outlined,
                                color: AppColors.burntOrange,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.burntOrange.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.restaurant_menu_outlined,
                              color: AppColors.burntOrange,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.burntOrange,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${rec.displayCoveragePercent} match',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.burntOrange.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreviewMessage extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PreviewMessage({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.cream.withValues(alpha: 0.8)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.cream.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}