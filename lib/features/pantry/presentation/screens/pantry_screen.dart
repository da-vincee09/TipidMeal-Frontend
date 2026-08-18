import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/core/extensions/context_extension.dart';

import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_create_request.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_model.dart';
import 'package:meal_recommendation_app/features/pantry/data/models/pantry_item_update_request.dart';
import 'package:meal_recommendation_app/features/pantry/presentation/providers/pantry_provider.dart';
import 'package:meal_recommendation_app/features/pantry/presentation/widgets/add_pantry_item_dialog.dart';
import 'package:meal_recommendation_app/features/pantry/presentation/widgets/pantry_item_card.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pantryControllerProvider.notifier).loadItems();
    });
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<PantryItemFormResult>(
      context: context,
      builder: (_) => const AddPantryItemDialog(),
    );

    if (result == null) return;

    final success = await ref.read(pantryControllerProvider.notifier).addItem(
          PantryItemCreateRequest(
            ingredient: result.ingredient,
            quantity: result.quantity,
            unit: result.unit,
          ),
        );

    if (!mounted) return;

    if (success) {
      context.showSuccessSnackBar('${result.ingredient} added to pantry', bottomMargin: 88);
    } else {
      context.showErrorSnackBar('Could not add item. Please try again.', bottomMargin: 88);
    }
  }

   Future<void> _openEditDialog(PantryItemModel item) async {
    final result = await showDialog<PantryItemFormResult>(
      context: context,
      builder: (_) => AddPantryItemDialog(item: item),
    );

    if (result == null) return;

    final success =
        await ref.read(pantryControllerProvider.notifier).updateItem(
              item.id,
              PantryItemUpdateRequest(
                ingredient: result.ingredient,
                quantity: result.quantity,
                unit: result.unit,
              ),
            );

    if (!mounted) return;

    if (success) {
      context.showSuccessSnackBar('${result.ingredient} updated', bottomMargin: 88);
    } else {
      context.showErrorSnackBar('Could not update item. Please try again.', bottomMargin: 88);
    }
  }

  Future<void> _confirmDelete(PantryItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Delete item?'),
        content: Text('Remove "${item.ingredient}" from your pantry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success =
        await ref.read(pantryControllerProvider.notifier).deleteItem(item.id);

    if (!mounted) return;

    if (success) {
      context.showSuccessSnackBar('${item.ingredient} removed from pantry', bottomMargin: 88);
    } else {
      context.showErrorSnackBar('Could not delete item. Please try again.', bottomMargin: 88);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pantryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Pantry',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        backgroundColor: AppColors.burntOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.burntOrange),
        ),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.read(pantryControllerProvider.notifier).loadItems(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            color: AppColors.burntOrange,
            onRefresh: () =>
                ref.read(pantryControllerProvider.notifier).loadItems(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return PantryItemCard(
                  item: item,
                  onEdit: () => _openEditDialog(item),
                  onDelete: () => _confirmDelete(item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.kitchen_outlined,
              size: 64,
              color: AppColors.burntOrange,
            ),
            const SizedBox(height: 16),
            Text(
              'Your pantry is empty',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add ingredients you have on hand to get personalized meal recommendations.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}