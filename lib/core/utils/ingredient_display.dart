String formatIngredientName(String raw) {
  return raw
      .split('_')
      .map((word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String toCanonicalIngredientName(String display) {
  return display.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
}