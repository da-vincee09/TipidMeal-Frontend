import 'package:shared_preferences/shared_preferences.dart';

class GroceryChecklistStorage {
  static const _keyPrefix = 'grocery_checked_';

  static String _keyFor(DateTime startDate) {
    final y = startDate.year.toString().padLeft(4, '0');
    final m = startDate.month.toString().padLeft(2, '0');
    final d = startDate.day.toString().padLeft(2, '0');
    return '$_keyPrefix$y-$m-$d';
  }

  static Future<Set<String>> load(DateTime startDate) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_keyFor(startDate));
    return stored?.toSet() ?? {};
  }

  static Future<void> save(DateTime startDate, Set<String> checked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFor(startDate), checked.toList());
  }

  /// Deletes checklist keys for weeks older than [maxAgeWeeks]. Call
  /// once per app launch (see main.dart) — cheap no-op on most runs
  /// since there's usually nothing to clean up, but keeps old weeks'
  /// keys from accumulating forever in SharedPreferences.
  static Future<void> cleanupOldWeeks({int maxAgeWeeks = 8}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.subtract(Duration(days: maxAgeWeeks * 7));

    final keysToRemove = <String>[];

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_keyPrefix)) continue;

      final dateStr = key.substring(_keyPrefix.length);
      final parsed = DateTime.tryParse(dateStr);

      // Malformed keys (shouldn't happen, but defensively) get removed
      // too rather than left behind forever.
      if (parsed == null || parsed.isBefore(cutoff)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }
}