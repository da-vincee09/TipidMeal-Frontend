import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:meal_recommendation_app/features/meals/data/models/meal_model.dart';

class MealCard extends ConsumerWidget {
  final MealModel meal;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 92,
                    height: 120,
                    child: meal.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: meal.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.burntOrange.withValues(alpha: 0.08),
                            ),
                            errorWidget: (context, url, error) =>
                                _placeholderIcon(),
                          )
                        : _placeholderIcon(),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: FavoriteButton(
                        mealId: meal.id,
                        mealName: meal.name,
                        estimatedCost: meal.estimatedCost,
                        imageUrl: meal.imageUrl,
                        activeColor: Colors.redAccent,
                        inactiveColor: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _MiniTag(
                            icon: Icons.timer_outlined,
                            label: '${meal.cookingTime} min',
                          ),
                          _MiniTag(
                            icon: Icons.bar_chart_rounded,
                            label: meal.difficulty,
                          ),
                          _MiniTag(
                            icon: Icons.people_outline,
                            label: '${meal.servings} servings',
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '₱${meal.displayCost}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.burntOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Center(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.burntOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: AppColors.burntOrange.withValues(alpha: 0.1),
      child: const Icon(
        Icons.restaurant_menu_outlined,
        color: AppColors.burntOrange,
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniTag({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: AppColors.burntOrange.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.lightSecondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}