import 'package:meal_recommendation_app/core/utils/date_utils.dart';

class MealPlanMealSummaryModel {
  final String id;
  final String name;
  final double estimatedCost;
  final String? imageUrl;

  const MealPlanMealSummaryModel({
    required this.id,
    required this.name,
    required this.estimatedCost,
    this.imageUrl,
  });

  factory MealPlanMealSummaryModel.fromJson(Map<String, dynamic> json) {
    return MealPlanMealSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      estimatedCost: _parseDecimal(json['estimated_cost']),
      imageUrl: json['image_url'] as String?,
    );
  }

  static double _parseDecimal(dynamic value) {
    if (value is String) return double.parse(value);
    if (value is num) return value.toDouble();
    throw FormatException('Unexpected estimated_cost type: ${value.runtimeType}');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'estimated_cost': estimatedCost,
      'image_url': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlanMealSummaryModel &&
        other.id == id &&
        other.name == name &&
        other.estimatedCost == estimatedCost &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => Object.hash(id, name, estimatedCost, imageUrl);
}

class MealPlanEntryModel {
  final String id;
  final MealPlanMealSummaryModel meal;
  final DateTime plannedDate;
  final String? mealSlot;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealPlanEntryModel({
    required this.id,
    required this.meal,
    required this.plannedDate,
    this.mealSlot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealPlanEntryModel.fromJson(Map<String, dynamic> json) {
    return MealPlanEntryModel(
      id: json['id'] as String,
      meal: MealPlanMealSummaryModel.fromJson(
        json['meal'] as Map<String, dynamic>,
      ),
      plannedDate: DateTime.parse(json['planned_date'] as String),
      mealSlot: json['meal_slot'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal': meal.toJson(),
      'planned_date': formatDate(plannedDate),
      'meal_slot': mealSlot,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'MealPlanEntryModel(id: $id, meal: ${meal.name}, '
      'plannedDate: $plannedDate, mealSlot: $mealSlot)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlanEntryModel &&
        other.id == id &&
        other.meal == meal &&
        other.plannedDate == plannedDate &&
        other.mealSlot == mealSlot &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, meal, plannedDate, mealSlot, createdAt, updatedAt);
}

class WeeklyPlanModel {
  final DateTime startDate;
  final DateTime endDate;
  final List<MealPlanEntryModel> entries;
  final double estimatedCostTotal;

  const WeeklyPlanModel({
    required this.startDate,
    required this.endDate,
    required this.entries,
    required this.estimatedCostTotal,
  });

  factory WeeklyPlanModel.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanModel(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => MealPlanEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      estimatedCostTotal: _parseDecimal(json['estimated_cost_total']),
    );
  }

  static double _parseDecimal(dynamic value) {
    if (value is String) return double.parse(value);
    if (value is num) return value.toDouble();
    throw FormatException(
      'Unexpected estimated_cost_total type: ${value.runtimeType}',
    );
  }

  /// Entries grouped by their planned date's calendar day (time-of-day stripped),
  /// convenient for driving a weekly calendar UI.
  Map<DateTime, List<MealPlanEntryModel>> get entriesByDay {
    final map = <DateTime, List<MealPlanEntryModel>>{};
    for (final entry in entries) {
      final day = DateTime(
        entry.plannedDate.year,
        entry.plannedDate.month,
        entry.plannedDate.day,
      );
      map.putIfAbsent(day, () => []).add(entry);
    }
    return map;
  }
}

