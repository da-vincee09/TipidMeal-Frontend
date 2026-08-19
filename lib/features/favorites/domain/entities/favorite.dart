class FavoriteMealSummary {
  final String id;
  final String name;
  final double estimatedCost;
  final String? imageUrl;

  const FavoriteMealSummary({
    required this.id,
    required this.name,
    required this.estimatedCost,
    this.imageUrl,
  });
}

class Favorite {
  final String id;
  final FavoriteMealSummary meal;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.meal,
    required this.createdAt,
  });
}