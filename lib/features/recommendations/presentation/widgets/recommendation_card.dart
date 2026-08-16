import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/features/recommendations/data/models/recommendation_model.dart';

class RecommendationCard extends StatelessWidget {
  final RecommendationModel recommendation;
  final VoidCallback onTap;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meal = recommendation.meal;
    final adaptation = recommendation.adaptation;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 96,
                    height: 120,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        meal.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: meal.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    _imagePlaceholder(),
                                errorWidget: (context, url, error) =>
                                    _placeholderImage(),
                              )
                            : _placeholderImage(),

                        // Recommended badge
                        Positioned(
                          top: 7,
                          left: 7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meal name and score
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              meal.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ScoreBadge(
                            label: recommendation.displayHybridScore,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Coverage information
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: AppColors.lightSecondaryText,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${recommendation.displayCoveragePercent} ingredients on hand',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.lightSecondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Coverage progress
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _coverageValue(
                            recommendation.displayCoveragePercent,
                          ),
                          minHeight: 5,
                          backgroundColor:
                              AppColors.burntOrange.withValues(alpha: 0.1),
                          color: AppColors.olive,
                        ),
                      ),

                      // Adaptations
                      if (adaptation.hasAdaptations) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (adaptation.substitutedIngredients.isNotEmpty)
                              _AdaptationChip(
                                icon: Icons.swap_horiz_rounded,
                                label:
                                    '${adaptation.substitutedIngredients.length} substituted',
                                color: AppColors.olive,
                              ),
                            if (adaptation.insufficientIngredients.isNotEmpty)
                              _AdaptationChip(
                                icon: Icons.warning_amber_rounded,
                                label:
                                    '${adaptation.insufficientIngredients.length} low stock',
                                color: AppColors.burntOrange,
                              ),
                            if (adaptation.omittedIngredients.isNotEmpty)
                              _AdaptationChip(
                                icon: Icons.remove_circle_outline_rounded,
                                label:
                                    '${adaptation.omittedIngredients.length} omitted',
                                color: AppColors.lightSecondaryText,
                              ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Bottom row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.burntOrange.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.payments_outlined,
                                  size: 14,
                                  color: AppColors.burntOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '₱${meal.displayCost}',
                                  style: const TextStyle(
                                    color: AppColors.burntOrange,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.burntOrange,
                            size: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _coverageValue(String value) {
    final percentage =
        double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));

    if (percentage == null) return 0;

    return (percentage / 100).clamp(0.0, 1.0);
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.burntOrange.withValues(alpha: 0.08),
      child: const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.burntOrange,
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.burntOrange.withValues(alpha: 0.1),
      child: const Icon(
        Icons.restaurant_menu_outlined,
        size: 34,
        color: AppColors.burntOrange,
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;

  const _ScoreBadge({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.burntOrange,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.burntOrange.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AdaptationChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}