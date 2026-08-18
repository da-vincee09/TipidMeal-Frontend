import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/features/grocery_list/data/grocery_checklist_storage.dart';
import 'package:meal_recommendation_app/features/grocery_list/presentation/providers/grocery_list_provider.dart';
import 'package:meal_recommendation_app/features/grocery_list/presentation/widgets/grocery_list_item_card.dart';

class GroceryListScreen extends ConsumerStatefulWidget {
  /// Both optional — omit both to let the backend default to the
  /// current Monday–Sunday week. When launched from the meal planner,
  /// pass the currently-viewed week so the list matches what's on screen.
  final DateTime? startDate;
  final DateTime? endDate;

  const GroceryListScreen({super.key, this.startDate, this.endDate});

  @override
  ConsumerState<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends ConsumerState<GroceryListScreen> {
  final Set<String> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(groceryListControllerProvider.notifier).loadGroceryList(
            startDate: widget.startDate,
            endDate: widget.endDate,
          );

      final saved = await GroceryChecklistStorage.load(_effectiveStartDate());
      if (mounted) setState(() => _checkedIngredients.addAll(saved));
    });
  }

  /// Mirrors the backend's default: Monday of the current week.
  /// Used as the persistence key when no explicit startDate was passed
  /// in (i.e. the screen is showing the backend's default "this week").
  DateTime _effectiveStartDate() {
    if (widget.startDate != null) return widget.startDate!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  void _reload() {
    ref.read(groceryListControllerProvider.notifier).loadGroceryList(
          startDate: widget.startDate,
          endDate: widget.endDate,
        );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groceryListControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grocery List',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.burntOrange),
        ),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: _reload,
        ),
        data: (list) {
          if (list == null || list.items.isEmpty) {
            return const _EmptyState();
          }

          final checkedCount = list.items
              .where((i) => _checkedIngredients.contains(i.ingredient))
              .length;

          return RefreshIndicator(
            color: AppColors.burntOrange,
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatDate(list.startDate)} – ${_formatDate(list.endDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightSecondaryText,
                      ),
                    ),
                    Text(
                      '$checkedCount/${list.items.length} checked',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.burntOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final item in list.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GroceryListItemCard(
                      item: item,
                      isChecked: _checkedIngredients.contains(item.ingredient),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _checkedIngredients.add(item.ingredient);
                          } else {
                            _checkedIngredients.remove(item.ingredient);
                          }
                        });
                        GroceryChecklistStorage.save(
                          _effectiveStartDate(),
                          _checkedIngredients,
                        );
                      },
                    ),
                  ),
              ],
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
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.burntOrange,
            ),
            const SizedBox(height: 16),
            Text('Nothing to buy', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Plan some meals for this week and we\'ll list what you still need.',
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