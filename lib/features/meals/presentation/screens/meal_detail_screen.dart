import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/core/utils/currency_utils.dart';
import 'package:meal_recommendation_app/features/meals/presentation/providers/meal_provider.dart';
import 'package:meal_recommendation_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:meal_recommendation_app/features/nutrition/data/models/nutrition_adequacy_model.dart';
import 'package:go_router/go_router.dart';

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
                              label: formatPeso(meal.estimatedCost),
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
                                    ingredient: ingredient.displayName,
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

                      // ================= NUTRITION =================
                      const SizedBox(height: 28),

                      _SectionHeader(
                        icon: Icons.eco_outlined,
                        title: 'Nutrition',
                      ),

                      const SizedBox(height: 10),

                      _NutritionSection(mealId: meal.id),

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
// NUTRITION SECTION
// ============================================================

class _NutritionSection extends ConsumerWidget {
  final String mealId;

  const _NutritionSection({required this.mealId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(mealNutritionAdequacyProvider(mealId));

    return nutritionAsync.when(
      loading: () => const _SectionCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.burntOrange,
              ),
            ),
          ),
        ),
      ),
      error: (error, _) => _SectionCard(
        child: Text(
          'Unable to load nutrition info right now.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.lightSecondaryText,
              ),
        ),
      ),
      data: (nutrition) => _NutritionCard(nutrition: nutrition),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final NutritionAdequacyModel nutrition;

  const _NutritionCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Caloric adequacy unavailable means the viewer hasn't set an
    // activity level yet — prompt to complete their profile instead
    // of showing a blank or misleading verdict.
    if (nutrition.isUnavailable) {
      return _SectionCard(
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.burntOrange,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Set your activity level in your profile to see how this meal fits your calorie needs.',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => context.push('/profile'),
              child: const Text('Set up'),
            ),
          ],
        ),
      );
    }

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Caloric verdict
          Row(
            children: [
              Icon(
                _caloricIcon(nutrition.caloricAdequacy),
                size: 20,
                color: _caloricColor(nutrition.caloricAdequacy),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nutrition.caloricAdequacyLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (nutrition.foodGroupProportions != null) ...[
            const SizedBox(height: 18),
            Text(
              'Food group breakdown',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.lightSecondaryText,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _FoodGroupPlate(
                  goPercent: nutrition.goPercent,
                  growPercent: nutrition.growPercent,
                  glowPercent: nutrition.glowPercent,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (nutrition.goPercent > 0)
                        _FoodGroupLegend(
                          color: _FoodGroupPlate.goColor,
                          label:
                              'Go ${nutrition.goPercent.toStringAsFixed(0)}%',
                        ),
                      if (nutrition.goPercent > 0) const SizedBox(height: 6),
                      if (nutrition.growPercent > 0)
                        _FoodGroupLegend(
                          color: _FoodGroupPlate.growColor,
                          label:
                              'Grow ${nutrition.growPercent.toStringAsFixed(0)}%',
                        ),
                      if (nutrition.growPercent > 0)
                        const SizedBox(height: 6),
                      if (nutrition.glowPercent > 0)
                        _FoodGroupLegend(
                          color: _FoodGroupPlate.glowColor,
                          label:
                              'Glow ${nutrition.glowPercent.toStringAsFixed(0)}%',
                        ),
                    ],
                  ),
                ),
              ],
            ),

            if (nutrition.foodGroupAdequate == false) ...[
              const SizedBox(height: 10),
              Text(
                'Outside the recommended Pinggang Pinoy range.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.lightSecondaryText,
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 10),
            Text(
              'Not enough classified ingredients to show a food-group breakdown.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.lightSecondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _caloricIcon(String adequacy) {
    switch (adequacy) {
      case 'within':
        return Icons.check_circle_rounded;
      case 'below':
        return Icons.arrow_downward_rounded;
      case 'above':
        return Icons.arrow_upward_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _caloricColor(String adequacy) {
    switch (adequacy) {
      case 'within':
        return AppColors.olive;
      case 'below':
      case 'above':
        return AppColors.burntOrange;
      default:
        return AppColors.lightSecondaryText;
    }
  }
}

// ============================================================
// FOOD GROUP PLATE (Pinggang Pinoy style)
// ============================================================

class _FoodGroupPlate extends StatelessWidget {
  final double goPercent;
  final double growPercent;
  final double glowPercent;

  const _FoodGroupPlate({
    required this.goPercent,
    required this.growPercent,
    required this.glowPercent,
  });

  // Pinggang Pinoy poster colors — DOST-FNRI has no published brand
  // hex spec, so these follow the poster's consistent orange/red/green scheme.
  static const goColor = Color(0xFFF5A623);
  static const growColor = Color(0xFFD64545);
  static const glowColor = Color(0xFF4CAF50);

  static const _size = 150.0;

  @override
  Widget build(BuildContext context) {
    final segments = <(double, Color, IconData)>[
      (goPercent, goColor, Icons.rice_bowl_outlined),
      (growPercent, growColor, Icons.egg_outlined),
      (glowPercent, glowColor, Icons.eco_outlined),
    ];

    // Compute each wedge's mid-angle so icons sit centered in their slice.
    final icons = <Widget>[];
    var startAngle = -math.pi / 2;
    const center = Offset(_size / 2, _size / 2);
    final iconRadius = _size / 2 * 0.6;

    // ignore: unused_local_variable
    for (final (percent, color, icon) in segments) {
      if (percent <= 0) continue;
      final sweep = (percent / 100) * 2 * math.pi;
      final midAngle = startAngle + sweep / 2;
      final pos = center +
          Offset(math.cos(midAngle), math.sin(midAngle)) * iconRadius;

      // Only show the icon if its slice is wide enough to hold it legibly.
      if (sweep > 0.35) {
        icons.add(Positioned(
          left: pos.dx - 11,
          top: pos.dy - 11,
          child: Icon(icon, size: 22, color: Colors.white),
        ));
      }
      startAngle += sweep;
    }

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(_size, _size),
            painter: _PlatePainter(
              goPercent: goPercent,
              growPercent: growPercent,
              glowPercent: glowPercent,
              goColor: goColor,
              growColor: growColor,
              glowColor: glowColor,
            ),
          ),
          ...icons,
        ],
      ),
    );
  }
}

class _PlatePainter extends CustomPainter {
  final double goPercent;
  final double growPercent;
  final double glowPercent;
  final Color goColor;
  final Color growColor;
  final Color glowColor;

  _PlatePainter({
    required this.goPercent,
    required this.growPercent,
    required this.glowPercent,
    required this.goColor,
    required this.growColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final plateRadius = size.width / 2 - 4;

    // Plate shadow for a lifted, dish-like feel.
    canvas.drawCircle(
      center.translate(0, 3),
      plateRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // White china base.
    canvas.drawCircle(center, plateRadius, Paint()..color = Colors.white);

    // Wedge sections, inset slightly to leave a visible plate rim.
    final wedgeRadius = plateRadius - 10;
    final rect = Rect.fromCircle(center: center, radius: wedgeRadius);

    final segments = <(double, Color)>[
      (goPercent, goColor),
      (growPercent, growColor),
      (glowPercent, glowColor),
    ];

    var startAngle = -math.pi / 2;
    for (final (percent, color) in segments) {
      if (percent <= 0) continue;
      final sweep = (percent / 100) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweep, true, Paint()..color = color);
      startAngle += sweep;
    }

    // Thin white dividing lines between wedges.
    startAngle = -math.pi / 2;
    final dividerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (final (percent, _) in segments) {
      if (percent <= 0) continue;
      final point = center +
          Offset(math.cos(startAngle), math.sin(startAngle)) * wedgeRadius;
      canvas.drawLine(center, point, dividerPaint);
      startAngle += (percent / 100) * 2 * math.pi;
    }

    // Double rim ring, like real plateware.
    canvas.drawCircle(
      center,
      plateRadius,
      Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      center,
      wedgeRadius + 4,
      Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Small white well in the very center.
    canvas.drawCircle(
      center,
      wedgeRadius * 0.12,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _PlatePainter oldDelegate) {
    return oldDelegate.goPercent != goPercent ||
        oldDelegate.growPercent != growPercent ||
        oldDelegate.glowPercent != glowPercent;
  }
}

class _FoodGroupLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _FoodGroupLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
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