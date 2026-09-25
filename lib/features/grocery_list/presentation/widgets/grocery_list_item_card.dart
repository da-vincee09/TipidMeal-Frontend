import 'package:flutter/material.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/features/grocery_list/data/models/grocery_list_model.dart';

class GroceryListItemCard extends StatelessWidget {
  final GroceryListItemModel item;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const GroceryListItemCard({
    super.key,
    required this.item,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isChecked ? 0.55 : 1.0,
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(!isChecked),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isChecked
                      ? AppColors.lightSecondaryText.withValues(alpha: 0.3)
                      : AppColors.burntOrange,
                  width: 4,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CheckCircle(isChecked: isChecked),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.ingredient,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            item.hasNoneInPantry
                                ? Icons.remove_shopping_cart_outlined
                                : Icons.kitchen_outlined,
                            size: 13,
                            color: item.hasNoneInPantry
                                ? AppColors.lightSecondaryText
                                : AppColors.burntOrange.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item.hasNoneInPantry
                                  ? 'None in pantry'
                                  : '${item.displayPantryQuantity} ${item.unit} on hand',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.lightSecondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isChecked
                            ? AppColors.lightSecondaryText.withValues(alpha: 0.12)
                            : AppColors.burntOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.displayQuantityToBuy} ${item.unit}',
                        style: TextStyle(
                          color: isChecked
                              ? AppColors.lightSecondaryText
                              : AppColors.burntOrange,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    if (item.displayEstimatedCost != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.displayEstimatedCost!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool isChecked;

  const _CheckCircle({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isChecked ? AppColors.burntOrange : Colors.transparent,
        border: Border.all(
          color: isChecked
              ? AppColors.burntOrange
              : AppColors.lightSecondaryText.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: isChecked
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}