import 'package:flutter/material.dart';

const Map<String, TimeOfDay> mealSlotCutoffs = {
  'breakfast': TimeOfDay(hour: 10, minute: 0),
  'lunch': TimeOfDay(hour: 14, minute: 0),
  'dinner': TimeOfDay(hour: 21, minute: 0),
};

bool isSlotPastToday(String slot, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final cutoff = mealSlotCutoffs[slot.toLowerCase()];
  if(cutoff == null) return false;
  final cutoffMinutes = cutoff.hour * 60 + cutoff.minute;
  final nowMinutes = n.hour * 60 + n.minute;
  return nowMinutes >= cutoffMinutes;
}

bool isDateBeforeToday(DateTime date, {DateTime? today}) {
  final t = today ?? DateTime.now();
  final d = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(t.year, t.month, t.day);
  return d.isBefore(todayOnly);
}