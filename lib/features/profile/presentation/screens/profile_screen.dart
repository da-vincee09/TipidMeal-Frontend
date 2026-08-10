import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/core/extensions/context_extension.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_model.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_update_request.dart';
import 'package:meal_recommendation_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:meal_recommendation_app/features/profile/presentation/widgets/profile_form.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;

  Future<void> _handleUpdate(ProfileFormData data) async {
    final request = ProfileUpdateRequest(
      firstName: data.firstName,
      lastName: data.lastName,
      dateOfBirth: data.dateOfBirth,
      sex: data.sex,
      dailyBudget: data.dailyBudget,
      cookingSkillLevel: data.cookingSkillLevel,
      foodAllergies: data.foodAllergies,
      dislikedIngredients: data.dislikedIngredients,
    );

    final success =
        await ref.read(profileControllerProvider.notifier).updateProfile(request);

    if (!mounted) return;

    if (success) {
      if (data.profileImageFile != null) {
        final imageSuccess = await ref
            .read(profileControllerProvider.notifier)
            .uploadProfileImage(data.profileImageFile!);

        if (!imageSuccess && mounted) {
          context.showSnackBar(
            'Profile updated, but the photo failed to upload.',
            isError: true,
          );
        }
      }

      if (mounted) {
        context.showSnackBar('Profile updated!');
        setState(() => _isEditing = false);
      }
    }
    // Failure of updateProfile() itself is surfaced by the ref.listen
    // error handler already in build().
  }

  Future<void> _handleCancelEdit(BuildContext context) async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'Any changes you made to your profile will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ProfileModel?>>(profileControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          context.showSnackBar(
            'Could not update profile. Please try again.',
            isError: true,
          );
        },
      );
    });

    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
       leading: _isEditing
        ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _handleCancelEdit(context),
          )
        : null,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SafeArea(
        child: profileState.when(
          data: (profile) {
            if (profile == null) {
              // Shouldn't be reachable (Home only routes here once a
              // profile exists), but guard rather than crash on null.
              return const Center(child: Text('No profile data available.'));
            }

            if (_isEditing) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: ProfileForm(
                  initialProfile: profile,
                  submitLabel: 'Save Changes',
                  isLoading: isLoading,
                  onSubmit: _handleUpdate,
                ),
              );
            }

            return _ProfileView(profile: profile);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Something went wrong loading your profile.'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        ref.read(profileControllerProvider.notifier).loadProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final ProfileModel profile;

  const _ProfileView({required this.profile});

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.burntOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _chipList(BuildContext context, String label, List<String> values) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.burntOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          values.isEmpty
              ? Text('None', style: theme.textTheme.bodyMedium)
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: values
                      .map((v) => Chip(
                            label: Text(v),
                            backgroundColor:
                                AppColors.olive.withValues(alpha: 0.15),
                            side: BorderSide.none,
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 64,
              backgroundColor: AppColors.burntOrange.withValues(alpha: 0.15),
              backgroundImage: profile.profileImageUrl != null
                  ? NetworkImage(profile.profileImageUrl!)
                  : null,
              child: profile.profileImageUrl == null
                  ? Text(
                      profile.firstName.isNotEmpty
                          ? profile.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.burntOrange,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          _row(context, 'Full Name', profile.fullName),
          _row(context, 'Date of Birth', _formatDate(profile.dateOfBirth)),
          _row(context, 'Sex', profile.sex),
          _row(context, 'Daily Budget', '₱${profile.dailyBudget.toStringAsFixed(0)}'),
          _row(context, 'Cooking Skill Level', profile.cookingSkillLevel),
          _chipList(
            context,
            'Food Allergies',
            profile.foodAllergies.map((e) => e.allergy).toList(),
          ),
          _chipList(
            context,
            'Disliked Ingredients',
            profile.dislikedIngredients.map((e) => e.ingredient).toList(),
          ),
        ],
      ),
    );
  }
}