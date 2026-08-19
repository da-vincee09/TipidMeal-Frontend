import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/core/extensions/context_extension.dart';
import 'package:meal_recommendation_app/features/favorites/presentation/providers/favorites_provider.dart';

class FavoriteButton extends ConsumerWidget {
  final String mealId;
  final String mealName;
  final double estimatedCost;
  final String? imageUrl;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;

  const FavoriteButton({
    super.key,
    required this.mealId,
    required this.mealName,
    required this.estimatedCost,
    this.imageUrl,
    this.activeColor,
    this.inactiveColor,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(favoritesControllerProvider);
    final controller = ref.read(favoritesControllerProvider.notifier);
    final isFavorited = controller.isFavorite(mealId);
    final theme = Theme.of(context);

    return IconButton(
      icon: Icon(
        isFavorited ? Icons.favorite : Icons.favorite_border,
        color: isFavorited
            ? (activeColor ?? theme.colorScheme.error)
            : inactiveColor,
        size: size,
      ),
      onPressed: () async {
        try {
          if (isFavorited) {
            await controller.removeFavorite(mealId);
          } else {
            await controller.addFavorite(
              mealId: mealId,
              mealName: mealName,
              estimatedCost: estimatedCost,
              imageUrl: imageUrl,
            );
          }
        } catch (e) {
          if (context.mounted) {
            context.showErrorSnackBar('Something went wrong. Please try again.');
          }
        }
      },
    );
  }
}