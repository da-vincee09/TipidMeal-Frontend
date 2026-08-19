import 'package:meal_recommendation_app/features/favorites/domain/entities/favorite.dart';

class FavoriteMealSummaryModel extends FavoriteMealSummary {
  const FavoriteMealSummaryModel({
    required super.id,
    required super.name,
    required super.estimatedCost,
    super.imageUrl,
  });

  factory FavoriteMealSummaryModel.fromJson(Map<String, dynamic> json) {
    return FavoriteMealSummaryModel(
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
}

class FavoriteModel extends Favorite {
  const FavoriteModel({
    required super.id,
    required FavoriteMealSummaryModel super.meal,
    required super.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String,
      meal: FavoriteMealSummaryModel.fromJson(json['meal'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}