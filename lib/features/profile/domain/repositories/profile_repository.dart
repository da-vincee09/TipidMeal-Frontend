import 'dart:io';
import 'package:meal_recommendation_app/features/profile/data/models/profile_create_request.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_model.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_update_request.dart';

abstract class ProfileRepository {
  Future<ProfileModel> createProfile(ProfileCreateRequest request);
  Future<ProfileModel> getMyProfile();
  Future<ProfileModel> updateProfile(ProfileUpdateRequest request);
  Future<String> uploadProfileImage(File imageFile);
}