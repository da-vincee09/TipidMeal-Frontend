import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/core/networks/network_providers.dart';
import 'package:meal_recommendation_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:meal_recommendation_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:meal_recommendation_app/features/profile/domain/repositories/profile_repository.dart';

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>((ref) {
  return ProfileRemoteDatasourceImpl(
    dio: ref.watch(dioProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    datasource: ref.watch(profileRemoteDatasourceProvider),
  );
});