import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/app/routes.dart';
import 'package:meal_recommendation_app/core/extensions/context_extension.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_create_request.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_model.dart';
import 'package:meal_recommendation_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:meal_recommendation_app/features/profile/presentation/widgets/profile_form.dart';

class ProfileSetupScreen extends ConsumerWidget {
  const ProfileSetupScreen({super.key});

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    ProfileFormData data,
  ) async {
    final request = ProfileCreateRequest(
      firstName: data.firstName,
      lastName: data.lastName,
      dateOfBirth: data.dateOfBirth,
      sex: data.sex,
      dailyBudget: data.dailyBudget,
      cookingSkillLevel: data.cookingSkillLevel,
      foodAllergies: data.foodAllergies,
      dislikedIngredients: data.dislikedIngredients,
    );

    final success = await ref.read(profileControllerProvider.notifier).createProfile(request);

    if (!context.mounted) return;

    if (success) {
      if (data.profileImageFile != null) {
        final imageSuccess = await ref
            .read(profileControllerProvider.notifier)
            .uploadProfileImage(data.profileImageFile!);

        if (!imageSuccess && context.mounted) {
          context.showSnackBar(
            'Profile created, but the photo failed to upload. '
            'You can add it later from your profile.',
            isError: true,
          );
        }
      }

      if (context.mounted) {
        context.showSnackBar('Profile created!');
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<ProfileModel?>>(profileControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          context.showSnackBar(
            'Could not create profile. Please try again.',
            isError: true,
          );
        },
      );
    });

    final isLoading = ref.watch(profileControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete Your Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tell us a bit about yourself so we can personalize your '
                'meal recommendations.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
              ),
              const SizedBox(height: 24),
              ProfileForm(
                submitLabel: 'Finish Setup',
                isLoading: isLoading,
                onSubmit: (data) => _handleSubmit(context, ref, data),
              ),
            ],
          ),
        ),
      ),
    );
  }
}