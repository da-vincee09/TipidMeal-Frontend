String formatPeso(num? value) {
  final v = value ?? 0;
  return '₱${v.toStringAsFixed(2)}';
}