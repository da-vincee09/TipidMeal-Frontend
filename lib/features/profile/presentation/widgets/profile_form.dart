import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/core/constants/profile_options.dart';
import 'package:meal_recommendation_app/core/extensions/context_extension.dart';
import 'package:meal_recommendation_app/features/profile/data/models/profile_model.dart';

class ProfileFormData {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String sex;
  final double dailyBudget;
  final String cookingSkillLevel;
  final List<String> foodAllergies;
  final List<String> dislikedIngredients;
  final File? profileImageFile;

  const ProfileFormData({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.sex,
    required this.dailyBudget,
    required this.cookingSkillLevel,
    required this.foodAllergies,
    required this.dislikedIngredients,
    this.profileImageFile,
  });
}

class ProfileForm extends StatefulWidget {
  final ProfileModel? initialProfile;
  final String submitLabel;
  final bool isLoading;
  final Future<void> Function(ProfileFormData data) onSubmit;

  const ProfileForm({
    super.key,
    this.initialProfile,
    required this.submitLabel,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _dailyBudgetController;

  DateTime? _dateOfBirth;
  String? _sex;
  String? _cookingSkillLevel;
  late Set<String> _selectedAllergies;
  late Set<String> _selectedDislikedIngredients;

  File? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  @override
  void initState() {
    super.initState();

    final p = widget.initialProfile;

    _firstNameController = TextEditingController(text: p?.firstName ?? '');
    _lastNameController = TextEditingController(text: p?.lastName ?? '');
    _dailyBudgetController = TextEditingController(
      text: p != null ? p.dailyBudget.toStringAsFixed(0) : '',
    );

    _dateOfBirth = p?.dateOfBirth;
    _sex = p?.sex;
    _cookingSkillLevel = p?.cookingSkillLevel;
    _selectedAllergies = p?.foodAllergies.map((e) => e.allergy).toSet() ?? {};
    _selectedDislikedIngredients =
        p?.dislikedIngredients.map((e) => e.ingredient).toSet() ?? {};
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dailyBudgetController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  InputDecoration _fieldDecoration(String hint, {Widget? prefixIcon, String? prefixText}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      prefixText: prefixText,
      filled: true,
      fillColor:
          isDark ? AppColors.darkInputBackground : AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: AppColors.burntOrange, width: 2),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.burntOrange,
        ),
      ),
    );
  }

  Widget _choiceChipRow({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: AppColors.burntOrange,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? AppColors.burntOrange : Colors.transparent,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _filterChipRow({
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onToggle(option),
          selectedColor: AppColors.olive.withValues(alpha: 0.85),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? AppColors.olive : Colors.transparent,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final budgetText = _dailyBudgetController.text.trim();

    if (firstName.length < 2) {
      context.showSnackBar(
        'First name must be at least 2 characters.',
        isError: true,
      );
      return;
    }

    if (lastName.length < 2) {
      context.showSnackBar(
        'Last name must be at least 2 characters.',
        isError: true,
      );
      return;
    }

    if (_dateOfBirth == null) {
      context.showSnackBar('Please select your date of birth.', isError: true);
      return;
    }

    if (_sex == null) {
      context.showSnackBar('Please select your sex.', isError: true);
      return;
    }

    final dailyBudget = double.tryParse(budgetText);
    if (dailyBudget == null || dailyBudget <= 0) {
      context.showSnackBar(
        'Please enter a valid daily budget.',
        isError: true,
      );
      return;
    }

    if (_cookingSkillLevel == null) {
      context.showSnackBar(
        'Please select your cooking skill level.',
        isError: true,
      );
      return;
    }

    widget.onSubmit(
      ProfileFormData(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: _dateOfBirth!,
        sex: _sex!,
        dailyBudget: dailyBudget,
        cookingSkillLevel: _cookingSkillLevel!,
        foodAllergies: _selectedAllergies.toList(),
        dislikedIngredients: _selectedDislikedIngredients.toList(),
        profileImageFile: _pickedImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Personal Information'),

        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundColor: AppColors.burntOrange.withValues(alpha: 0.15),
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!) as ImageProvider
                      : (widget.initialProfile?.profileImageUrl != null
                          ? NetworkImage(widget.initialProfile!.profileImageUrl!)
                          : null),
                  child: _pickedImage == null &&
                          widget.initialProfile?.profileImageUrl == null
                      ? const Icon(Icons.person, size: 60, color: AppColors.burntOrange)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.burntOrange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        TextField(
          controller: _firstNameController,
          textInputAction: TextInputAction.next,
          decoration: _fieldDecoration('First Name'),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _lastNameController,
          textInputAction: TextInputAction.next,
          decoration: _fieldDecoration('Last Name'),
        ),
        const SizedBox(height: 12),

        InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: _pickDateOfBirth,
          child: InputDecorator(
            decoration: _fieldDecoration(
              'Date of Birth',
              prefixIcon: const Icon(Icons.cake_outlined),
            ),
            child: Text(
              _dateOfBirth != null ? _formatDate(_dateOfBirth!) : '',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _dateOfBirth != null
                    ? null
                    : (isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text('Sex', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        _choiceChipRow(
          options: ProfileOptions.sexOptions,
          selected: _sex,
          onSelected: (value) => setState(() => _sex = value),
        ),

        const SizedBox(height: 20),
        _sectionTitle('Food Information'),

        TextField(
          controller: _dailyBudgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          decoration: _fieldDecoration('Daily Budget', prefixText: '₱ '),
        ),
        const SizedBox(height: 16),

        Text('Cooking Skill Level', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        _choiceChipRow(
          options: ProfileOptions.cookingSkillLevels,
          selected: _cookingSkillLevel,
          onSelected: (value) => setState(() => _cookingSkillLevel = value),
        ),

        const SizedBox(height: 16),

        Text('Food Allergies', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        _filterChipRow(
          options: ProfileOptions.foodAllergies,
          selected: _selectedAllergies,
          onToggle: (value) {
            setState(() {
              _selectedAllergies.contains(value)
                  ? _selectedAllergies.remove(value)
                  : _selectedAllergies.add(value);
            });
          },
        ),

        const SizedBox(height: 16),

        Text('Disliked Ingredients', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        _filterChipRow(
          options: ProfileOptions.dislikedIngredients,
          selected: _selectedDislikedIngredients,
          onToggle: (value) {
            setState(() {
              _selectedDislikedIngredients.contains(value)
                  ? _selectedDislikedIngredients.remove(value)
                  : _selectedDislikedIngredients.add(value);
            });
          },
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.burntOrange,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.submitLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}