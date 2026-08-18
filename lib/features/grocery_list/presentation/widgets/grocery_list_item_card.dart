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

    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => onChanged(!isChecked),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: onChanged,
                activeColor: AppColors.burntOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
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
                        color: isChecked
                            ? theme.textTheme.bodySmall?.color
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.hasNoneInPantry
                          ? 'None in pantry'
                          : '${item.displayPantryQuantity} ${item.unit} in pantry · needs ${item.displayRequiredQuantity} ${item.unit}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.burntOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${item.displayQuantityToBuy} ${item.unit}',
                  style: const TextStyle(
                    color: AppColors.burntOrange,
                    fontWeight: FontWeight.w700,
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