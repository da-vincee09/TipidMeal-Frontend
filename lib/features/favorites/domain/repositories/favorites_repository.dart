import 'package:meal_recommendation_app/features/favorites/domain/entities/favorite.dart';

abstract class FavoritesRepository {
  Future<Favorite> addFavorite(String mealId);
  Future<List<Favorite>> getFavorites();
  Future<void> removeFavorite(String mealId);
}