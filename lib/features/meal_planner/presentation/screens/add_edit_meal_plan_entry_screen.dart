import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/core/extensions/context_extension.dart';
import 'package:meal_recommendation_app/core/widgets/confirm_dialog.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_model.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_request.dart';
import 'package:meal_recommendation_app/features/meal_planner/presentation/providers/meal_planner_provider.dart';
import 'package:meal_recommendation_app/features/meals/data/models/meal_model.dart';
import 'package:meal_recommendation_app/features/meals/presentation/providers/meal_provider.dart';

class AddEditMealPlanEntryScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final MealPlanEntryModel? existingEntry;

  const AddEditMealPlanEntryScreen({
    super.key,
    this.initialDate,
    this.existingEntry,
  });

  bool get isEditing => existingEntry != null;

  @override
  ConsumerState<AddEditMealPlanEntryScreen> createState() =>
      _AddEditMealPlanEntryScreenState();
}

class _AddEditMealPlanEntryScreenState
    extends ConsumerState<AddEditMealPlanEntryScreen> {
  late DateTime _selectedDate;
  String? _selectedSlot;
  String? _selectedMealId;
  String _mealSearchQuery = '';
  bool _isSaving = false;

  static const _slots = ['breakfast', 'lunch', 'dinner'];
  static const _slotLabels = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
  };

  @override
  void initState() {
    super.initState();

    final entry = widget.existingEntry;
    _selectedDate = entry?.plannedDate ?? widget.initialDate ?? DateTime.now();
    _selectedSlot = entry?.mealSlot?.toLowerCase();
    _selectedMealId = entry?.meal.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mealControllerProvider.notifier).loadMeals();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_selectedMealId == null) {
      context.showErrorSnackBar('Please select a meal');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final controller = ref.read(mealPlanControllerProvider.notifier);

      if (widget.isEditing) {
        await controller.updateEntry(
          widget.existingEntry!.id,
          MealPlanEntryUpdateRequest(
            plannedDate: _selectedDate,
            mealSlot: _selectedSlot,
          ),
        );
      } else {
        await controller.addEntry(
          MealPlanEntryCreateRequest(
            mealId: _selectedMealId!,
            plannedDate: _selectedDate,
            mealSlot: _selectedSlot,
          ),
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove from plan?',
      message: 'This meal will be removed from your plan.',
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(mealPlanControllerProvider.notifier)
          .removeEntry(widget.existingEntry!.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Failed to remove: $e');
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealsState = ref.watch(mealControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Planned Meal' : 'Add to Plan',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: _isSaving ? null : _delete,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(_formatDate(_selectedDate)),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Meal Slot', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _slots.map((slot) {
                    final isSelected = _selectedSlot == slot;
                    return ChoiceChip(
                      label: Text(_slotLabels[slot]!),
                      selected: isSelected,
                      onSelected: (_) => setState(
                        () => _selectedSlot = isSelected ? null : slot,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Meal', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search meals...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) =>
                      setState(() => _mealSearchQuery = value.toLowerCase()),
                ),
              ],
            ),
          ),
          Expanded(
            child: mealsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Failed to load meals: $error')),
              data: (meals) {
                final filtered = _mealSearchQuery.isEmpty
                    ? meals
                    : meals
                        .where((m) => m.name.toLowerCase().contains(_mealSearchQuery))
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No meals found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final meal = filtered[index];
                    final isSelected = _selectedMealId == meal.id;
                    return _MealPickerTile(
                      meal: meal,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedMealId = meal.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.isEditing ? 'Save Changes' : 'Add to Plan'),
          ),
        ),
      ),
    );
  }
}

class _MealPickerTile extends StatelessWidget {
  final MealModel meal;
  final bool isSelected;
  final VoidCallback onTap;

  const _MealPickerTile({
    required this.meal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: meal.imageUrl != null
              ? Image.network(
                  meal.imageUrl!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  // ignore: unnecessary_underscores
                  errorBuilder: (_, __, ___) => const Icon(Icons.restaurant),
                )
              : const Icon(Icons.restaurant),
        ),
        title: Text(meal.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('₱${meal.displayCost}'),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
      ),
    );
  }
}