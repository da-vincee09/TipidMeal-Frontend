import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/core/errors/api_exception.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_create_request.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_model.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_update_request.dart';
import 'package:meal_recommendation_app/features/profile/data/profile_dependencies.dart';

final profileControllerProvider =
    NotifierProvider<ProfileController, AsyncValue<ProfileModel?>>(
  ProfileController.new,
);


class ProfileController extends Notifier<AsyncValue<ProfileModel?>> {
  @override
  AsyncValue<ProfileModel?> build() {
    // Idle state until loadProfile() is explicitly called (e.g. from the
    // splash screen). We deliberately don't auto-load here, so callers
    // control exactly when the network request happens.
    return const AsyncData(null);
  }

  Future<void> loadProfile() async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(profileRepositoryProvider);
      final profile = await repository.getMyProfile();
      state = AsyncData(profile);
    } on ProfileNotFoundException {
      // Not an error — this is the expected "needs onboarding" signal.
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> createProfile(ProfileCreateRequest request) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(profileRepositoryProvider);
      final profile = await repository.createProfile(request);
      state = AsyncData(profile);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateProfile(ProfileUpdateRequest request) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(profileRepositoryProvider);
      final profile = await repository.updateProfile(request);
      state = AsyncData(profile);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> uploadProfileImage(File imageFile) async {
    final currentProfile = state is AsyncData<ProfileModel?>
        ? (state as AsyncData<ProfileModel?>).value
        : null;

    if (currentProfile == null) return false;

    try {
      final repository = ref.read(profileRepositoryProvider);
      final imageUrl = await repository.uploadProfileImage(imageFile);
      state = AsyncData(currentProfile.copyWith(profileImageUrl: imageUrl));
      return true;
    } catch (e) {
      return false;
    }
  }
}