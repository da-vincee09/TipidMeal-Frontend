import 'package:flutter/material.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_model.dart';

class MealPlanEntryCard extends StatelessWidget {
  final MealPlanEntryModel entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MealPlanEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: entry.meal.imageUrl != null
              ? Image.network(
                  entry.meal.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  // ignore: unnecessary_underscores
                  errorBuilder: (_, __, ___) => _placeholderIcon(theme),
                )
              : _placeholderIcon(theme),
        ),
        title: Text(
          entry.meal.name,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '₱${entry.meal.estimatedCost.toStringAsFixed(0)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: Icon(Icons.close, size: 20, color: theme.colorScheme.error),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }

  Widget _placeholderIcon(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      color: theme.colorScheme.secondaryContainer,
      child: Icon(
        Icons.restaurant,
        color: theme.colorScheme.secondary,
        size: 24,
      ),
    );
  }
}