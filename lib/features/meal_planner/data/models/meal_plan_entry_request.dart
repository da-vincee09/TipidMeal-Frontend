

import 'package:meal_recommendation_app/core/utils/date_utils.dart';

class MealPlanEntryCreateRequest {
  final String mealId;
  final DateTime plannedDate;
  final String? mealSlot;

  const MealPlanEntryCreateRequest({
    required this.mealId,
    required this.plannedDate,
    this.mealSlot,
  });

  Map<String, dynamic> toJson() {
    return {
      'meal_id': mealId,
      'planned_date': formatDate(plannedDate),
      'meal_slot': mealSlot,
    };
  }
}

class MealPlanEntryUpdateRequest {
  final DateTime? plannedDate;
  final String? mealSlot;

  const MealPlanEntryUpdateRequest({
    this.plannedDate,
    this.mealSlot,
  });

  Map<String, dynamic> toJson() {
    return {
      if (plannedDate != null) 'planned_date': formatDate(plannedDate!),
      'meal_slot': mealSlot,
    };
  }
}