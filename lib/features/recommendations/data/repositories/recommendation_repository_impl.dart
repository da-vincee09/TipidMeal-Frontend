import 'package:meal_recommendation_app/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:meal_recommendation_app/features/recommendations/data/models/recommendation_model.dart';
import 'package:meal_recommendation_app/features/recommendations/domain/repositories/recommendation_repository.dart';


class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationsRemoteDatasource datasource;

  RecommendationRepositoryImpl({required this.datasource});

  @override
  Future<List<RecommendationModel>> getRecommendations() {
    return datasource.getRecommendations();
  }
}