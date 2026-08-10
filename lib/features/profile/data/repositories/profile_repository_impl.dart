import 'dart:io';
import 'package:meal_recommendation_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_create_request.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_model.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_update_request.dart';
import 'package:meal_recommendation_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource datasource;

  ProfileRepositoryImpl({required this.datasource});

  @override
  Future<ProfileModel> createProfile(ProfileCreateRequest request) {
    return datasource.createProfile(request);
  }

  @override
  Future<ProfileModel> getMyProfile() {
    return datasource.getMyProfile();
  }

  @override
  Future<ProfileModel> updateProfile(ProfileUpdateRequest request) {
    return datasource.updateProfile(request);
  }

  @override
  Future<String> uploadProfileImage(File imageFile) {
    return datasource.uploadProfileImage(imageFile);
  }
}