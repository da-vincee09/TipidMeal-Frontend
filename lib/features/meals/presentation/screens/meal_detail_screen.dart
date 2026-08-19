import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/features/meals/presentation/providers/meal_provider.dart';
import 'package:meal_recommendation_app/features/favorites/presentation/widgets/favorite_button.dart';

class MealDetailScreen extends ConsumerWidget {
  final String mealId;

  const MealDetailScreen({
    super.key,
    required this.mealId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealAsync = ref.watch(mealDetailProvider(mealId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: mealAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.burntOrange,
          ),
        ),

        error: (error, stackTrace) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(mealDetailProvider(mealId)),
        ),

        data: (meal) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ================= HERO APP BAR =================
                            SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.burntOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                actions: [
                  FavoriteButton(
                    mealId: meal.id,
                    mealName: meal.name,
                    estimatedCost: meal.estimatedCost,
                    imageUrl: meal.imageUrl,
                    activeColor: Colors.redAccent,
                    inactiveColor: Colors.white,
                  ),
                  const SizedBox(width: 4),
                ],
                flexibleSpace: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    FlexibleSpaceBar(
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          _MealHeroImage(
                            imageUrl: meal.imageUrl,
                          ),

                          // Dark gradient
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.20),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Title stays at bottom-left
                    Positioned(
                      left: 50,
                      right: 20,
                      bottom: 18,
                      child: SafeArea(
                        top: false,
                        child: Text(
                          meal.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= CONTENT =================
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // ================= QUICK INFO =================
                      _SectionCard(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _InfoChip(
                              icon: Icons.timer_outlined,
                              label: '${meal.cookingTime} min',
                            ),
                            _InfoChip(
                              icon: Icons.bar_chart_rounded,
                              label: meal.difficulty,
                            ),
                            _InfoChip(
                              icon: Icons.people_outline_rounded,
                              label: '${meal.servings} servings',
                            ),
                            if (meal.calories != null)
                              _InfoChip(
                                icon: Icons.local_fire_department_outlined,
                                label: '${meal.calories} kcal',
                              ),
                            _InfoChip(
                              icon: Icons.payments_outlined,
                              label: '₱${meal.displayCost}',
                            ),
                          ],
                        ),
                      ),

                      // ================= DESCRIPTION =================
                      if (meal.description != null &&
                          meal.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 24),

                        _SectionHeader(
                          icon: Icons.restaurant_outlined,
                          title: 'About this meal',
                        ),

                        const SizedBox(height: 10),

                        _SectionCard(
                          child: Text(
                            meal.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],

                      // ================= INGREDIENTS =================
                      const SizedBox(height: 28),

                      _SectionHeader(
                        icon: Icons.shopping_basket_outlined,
                        title: 'Ingredients',
                        trailing: '${meal.ingredients.length} items',
                      ),

                      const SizedBox(height: 10),

                      _SectionCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: List.generate(
                            meal.ingredients.length,
                            (index) {
                              final ingredient = meal.ingredients[index];

                              return Column(
                                children: [
                                  _IngredientTile(
                                    quantity: ingredient.displayQuantity,
                                    unit: ingredient.unit,
                                    ingredient: ingredient.ingredient,
                                    isOptional: ingredient.isOptional,
                                  ),
                                  if (index != meal.ingredients.length - 1)
                                    Divider(
                                      height: 1,
                                      indent: 56,
                                      endIndent: 16,
                                      color: theme.dividerColor
                                          .withValues(alpha: 0.5),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      // ================= INSTRUCTIONS =================
                      const SizedBox(height: 28),

                      _SectionHeader(
                        icon: Icons.format_list_numbered_rounded,
                        title: 'Instructions',
                        trailing: '${meal.instructions.length} steps',
                      ),

                      const SizedBox(height: 10),

                      _SectionCard(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: List.generate(
                            meal.instructions.length,
                            (index) {
                              final step = meal.instructions[index];

                              return _InstructionTile(
                                stepNumber: step.stepNumber,
                                instruction: step.instruction,
                                isLast:
                                    index == meal.instructions.length - 1,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// HERO IMAGE
// ============================================================

class _MealHeroImage extends StatelessWidget {
  final String? imageUrl;

  const _MealHeroImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (context, url) => Container(
        color: AppColors.burntOrange.withValues(alpha: 0.25),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.burntOrange,
      child: const Center(
        child: Icon(
          Icons.restaurant_menu_outlined,
          size: 72,
          color: Colors.white70,
        ),
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.burntOrange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.burntOrange,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.burntOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

// ============================================================
// SECTION CARD
// ============================================================

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.burntOrange.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.burntOrange.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: AppColors.burntOrange,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INGREDIENT TILE
// ============================================================

class _IngredientTile extends StatelessWidget {
  final String quantity;
  final String unit;
  final String ingredient;
  final bool isOptional;

  const _IngredientTile({
    required this.quantity,
    required this.unit,
    required this.ingredient,
    required this.isOptional,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final amount = [
      quantity,
      if (unit.trim().isNotEmpty) unit,
    ].join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.burntOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 16,
              color: AppColors.burntOrange,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              ingredient,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (amount.trim().isNotEmpty)
                Text(
                  amount,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.burntOrange,
                  ),
                ),
              if (isOptional)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Optional',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INSTRUCTION TILE
// ============================================================

class _InstructionTile extends StatelessWidget {
  final int stepNumber;
  final String instruction;
  final bool isLast;

  const _InstructionTile({
    required this.stepNumber,
    required this.instruction,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.burntOrange,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: AppColors.burntOrange.withValues(alpha: 0.18),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                  instruction,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load meal',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}