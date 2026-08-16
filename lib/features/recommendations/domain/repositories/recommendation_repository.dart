import 'package:meal_recommendation_app/features/recommendations/data/models/recommendation_model.dart';

abstract class RecommendationRepository {
  Future<List<RecommendationModel>> getRecommendations();
}