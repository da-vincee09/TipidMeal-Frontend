import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/core/networks/network_providers.dart';
import 'package:meal_recommendation_app/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:meal_recommendation_app/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:meal_recommendation_app/features/recommendations/domain/repositories/recommendation_repository.dart';


final recommendationsRemoteDatasourceProvider =
    Provider<RecommendationsRemoteDatasource>((ref) {
  return RecommendationsRemoteDatasourceImpl(
    dio: ref.watch(dioProvider),
  );
});

final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  return RecommendationRepositoryImpl(
    datasource: ref.watch(recommendationsRemoteDatasourceProvider),
  );
});