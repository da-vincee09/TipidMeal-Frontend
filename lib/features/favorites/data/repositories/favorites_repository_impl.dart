import 'package:meal_recommendation_app/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:meal_recommendation_app/features/favorites/domain/entities/favorite.dart';
import 'package:meal_recommendation_app/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDatasource datasource;

  FavoritesRepositoryImpl({required this.datasource});

  @override
  Future<Favorite> addFavorite(String mealId) {
    return datasource.addFavorite(mealId);
  }

  @override
  Future<List<Favorite>> getFavorites() {
    return datasource.getFavorites();
  }

  @override
  Future<void> removeFavorite(String mealId) {
    return datasource.removeFavorite(mealId);
  }
}