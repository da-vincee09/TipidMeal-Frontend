import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/app/routes.dart';
import 'package:meal_recommendation_app/core/extensions/context_extension.dart';
import 'package:meal_recommendation_app/features/authentication/presentation/providers/auth_provider.dart';
import 'package:meal_recommendation_app/features/profile/presentation/providers/profile_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty) {
      context.showSnackBar('Please enter your email.', isError: true);
      return;
    }

    if (password.isEmpty) {
      context.showSnackBar('Please enter your password.', isError: true);
      return;
    }

    if (password.length < 6) {
      context.showSnackBar(
        'Password must be at least 6 characters.',
        isError: true,
      );
      return;
    }

    if (password != confirmPassword) {
      context.showSnackBar('Passwords do not match.', isError: true);
      return;
    }

    await ref.read(authControllerProvider.notifier).signUp(
          email: email,
          password: password,
        );
  }

  /// Runs right after a successful signUp(). A brand-new account will
  /// always be missing a profile (loadProfile() -> 404 -> AsyncData(null)),
  /// so in practice this always routes to ProfileSetupScreen — but we still
  /// go through the same check as Login/Splash rather than hardcoding that
  /// assumption, in case the backend is ever changed to auto-create a
  /// default profile row on signup.
  Future<void> _handlePostRegister() async {
    await ref.read(profileControllerProvider.notifier).loadProfile();

    if (!mounted) return;

    final profileState = ref.read(profileControllerProvider);

    profileState.when(
      data: (profile) {
        context.showSnackBar('Account created!');
        if (profile == null) {
          context.go(AppRoutes.profileSetup);
        } else {
          context.go(AppRoutes.home);
        }
      },
      loading: () {}, // unreachable — loadProfile() was awaited above
      error: (error, _) {
        context.showSnackBar(
          'Account created, but could not load your profile. Please try again.',
          isError: true,
        );
      },
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor:
          isDark ? AppColors.darkInputBackground : AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
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
        borderSide: const BorderSide(
          color: AppColors.burntOrange,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            context.showSnackBar(error.toString(), isError: true);
          },
          data: (_) {
            if (previous?.isLoading ?? false) {
              _handlePostRegister();
            }
          },
        );
      },
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.burntOrange,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // ======================================================
            // HERO SECTION
            // ======================================================
            Expanded(
              flex: 50,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final heroHeight = constraints.maxHeight;
                  final circleSize = heroHeight * 0.75;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // FOOD IMAGE
                      Positioned(
                        left: -circleSize * 0.42,
                        top: heroHeight * 0.08,
                        child: Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.7),
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image:
                                  AssetImage('assets/images/login_food.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // WELCOME TEXT
                      Positioned(
                        left: circleSize * 0.72,
                        right: 20,
                        top: heroHeight * 0.20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: AppColors.cream,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Start your journey to smarter, '
                              'more affordable cooking today.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    AppColors.cream.withValues(alpha: 0.9),
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // APP NAME
                      Positioned(
                        left: 24,
                        bottom: 8,
                        child: Text(
                          'TipidMeal',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.cream.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ======================================================
            // SIGN UP CARD
            // ======================================================
            Expanded(
              flex: 50,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Sign Up',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.burntOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_passwordFocusNode),
                        decoration: _fieldDecoration(
                          hint: 'Email Address',
                          isDark: isDark,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Password
                      TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_confirmPasswordFocusNode),
                        decoration: _fieldDecoration(
                          hint: 'Password',
                          isDark: isDark,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Confirm Password
                      TextField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _register(),
                        decoration: _fieldDecoration(
                          hint: 'Confirm Password',
                          isDark: isDark,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Done Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.burntOrange,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Done',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Already have an account? Log in
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                                ),
                              ),
                              TextSpan(
                                text: 'Log in',
                                style: const TextStyle(
                                  color: AppColors.olive,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push(AppRoutes.login);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}