import 'package:flutter/material.dart';
import 'package:meal_recommendation_app/features/favorites/domain/entities/favorite.dart';

class FavoriteMealCard extends StatelessWidget {
  final Favorite favorite;
  final VoidCallback? onTap;

  const FavoriteMealCard({super.key, required this.favorite, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meal = favorite.meal;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: meal.imageUrl != null
              ? Image.network(
                  meal.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  // ignore: unnecessary_underscores
                  errorBuilder: (_, __, ___) => _placeholder(theme),
                )
              : _placeholder(theme),
        ),
        title: Text(meal.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('₱${meal.estimatedCost.toStringAsFixed(0)}'),
        trailing: Icon(Icons.favorite, color: theme.colorScheme.error, size: 20),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) => Container(
        width: 48,
        height: 48,
        color: theme.colorScheme.secondaryContainer,
        child: Icon(Icons.restaurant, color: theme.colorScheme.secondary),
      );
}