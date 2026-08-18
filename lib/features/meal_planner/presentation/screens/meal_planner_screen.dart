import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_recommendation_app/core/extensions/context_extension.dart';
import 'package:meal_recommendation_app/core/widgets/confirm_dialog.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_model.dart';
import 'package:meal_recommendation_app/features/meal_planner/presentation/providers/meal_planner_provider.dart';
import 'package:meal_recommendation_app/features/meal_planner/presentation/widgets/day_stab_strip.dart';
import 'package:meal_recommendation_app/features/meal_planner/presentation/widgets/meal_plan_entry_card.dart';

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  late DateTime _weekStart;
  late DateTime _selectedDay;

  static const _slotOrder = ['breakfast', 'lunch', 'dinner'];
  static const _slotLabels = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
  };

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _weekStart = _mondayOf(today);
    _selectedDay = DateTime(today.year, today.month, today.day);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWeek());
  }

  DateTime _mondayOf(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  void _loadWeek() {
    ref.read(mealPlanControllerProvider.notifier).loadWeek(
          startDate: _weekStart,
          endDate: _weekStart.add(const Duration(days: 6)),
        );
  }

  void _goToPreviousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedDay = _weekStart;
    });
    _loadWeek();
  }

  void _goToNextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedDay = _weekStart;
    });
    _loadWeek();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthYearLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

   Future<void> _openAddEntry() async {
    final result = await context.push<bool>(
      '/meal-planner/add',
      extra: {'date': _selectedDay},
    );
    if (result == true && mounted) {
      context.showSuccessSnackBar('Added to plan', bottomMargin: 88);
    }
  }

  Future<void> _openEditEntry(MealPlanEntryModel entry) async {
    final result = await context.push<bool>(
      '/meal-planner/add',
      extra: {'entry': entry},
    );
    if (result == true && mounted) {
      context.showSuccessSnackBar('Plan updated', bottomMargin: 88);
    }
  }

  Future<void> _confirmAndDelete(MealPlanEntryModel entry) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove from plan?',
      message: '${entry.meal.name} will be removed from your plan.',
    );

    if (confirmed != true) return;

    try {
      await ref.read(mealPlanControllerProvider.notifier).removeEntry(entry.id);
      if (mounted) context.showSuccessSnackBar('Removed from plan', bottomMargin: 88);
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Failed to remove: $e', bottomMargin: 88);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meal Planner',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
         actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Grocery List',
            onPressed: () => context.push(
              '/grocery-list',
              extra: {
                'startDate': _weekStart,
                'endDate': _weekStart.add(const Duration(days: 6)),
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _goToPreviousWeek,
                ),
                Text(
                  _monthYearLabel(_weekStart),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _goToNextWeek,
                ),
              ],
            ),
          ),
          state.when(
            loading: () => const SizedBox(
              height: 72,
              child: Center(child: CircularProgressIndicator()),
            ),
            // ignore: unnecessary_underscores
            error: (_, __) => const SizedBox.shrink(),
            data: (plan) {
              final daysWithEntries = plan == null
                  ? <DateTime>{}
                  : plan.entriesByDay.keys.toSet();

              return DayTabStrip(
                days: _weekDays,
                selectedDay: _selectedDay,
                daysWithEntries: daysWithEntries,
                onDaySelected: (day) => setState(() => _selectedDay = day),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: error.toString(),
                onRetry: _loadWeek,
              ),
              data: (plan) {
                if (plan == null) {
                  return const _EmptyState();
                }

                final entriesForDay = plan.entries
                    .where((e) => _isSameDay(e.plannedDate, _selectedDay))
                    .toList();

                if (entriesForDay.isEmpty) {
                  return const _EmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadWeek(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    children: _buildSlotSections(entriesForDay),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEntry,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildSlotSections(List<MealPlanEntryModel> entriesForDay) {
    final bySlot = <String, List<MealPlanEntryModel>>{};
    for (final entry in entriesForDay) {
      final slotKey = entry.mealSlot?.toLowerCase() ?? 'other';
      bySlot.putIfAbsent(slotKey, () => []).add(entry);
    }

    final orderedKeys = [
      ..._slotOrder.where(bySlot.containsKey),
      ...bySlot.keys.where((k) => !_slotOrder.contains(k)),
    ];

    final widgets = <Widget>[];
    for (final key in orderedKeys) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            _slotLabels[key] ?? _capitalize(key),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      );
      for (final entry in bySlot[key]!) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MealPlanEntryCard(
              entry: entry,
              onTap: () => _openEditEntry(entry),
              onDelete: () => _confirmAndDelete(entry),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
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
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text('No meals planned', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a meal to this day.',
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