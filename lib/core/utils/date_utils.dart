/// Formats a DateTime as `YYYY-MM-DD`, matching the backend's `date` type
/// (no time component, no intl dependency needed).
String formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}