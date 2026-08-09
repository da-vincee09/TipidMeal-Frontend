import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/app/routes.dart';
import 'package:meal_recommendation_app/core/extensions/context_extension.dart';
import 'package:meal_recommendation_app/features/authentication/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      context.showSnackBar(
        'Please enter your email.',
        isError: true,
      );
      return;
    }

    if (password.isEmpty) {
      context.showSnackBar(
        'Please enter your password.',
        isError: true,
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).signIn(
          email: email,
          password: password,
        );

  }


  @override
  Widget build(BuildContext context) {

    ref.listen<AsyncValue<void>>(
      authControllerProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            context.showSnackBar(
              error.toString(),
              isError: true,
            );
          },
          data: (_) {
            if (previous?.isLoading ?? false) {
              context.showSnackBar(
                'Login successful!',
              );

              context.go(AppRoutes.home);
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
        bottom: false,
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
                  final circleSize = heroHeight * 0.75; // scales with available space

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ─────────────────────────────────────
                      // FOOD IMAGE
                      // ─────────────────────────────────────
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
                              image: AssetImage('assets/images/login_food.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // ─────────────────────────────────────
                      // WELCOME TEXT
                      // ─────────────────────────────────────
                      Positioned(
                        left: circleSize * 0.72,   // was 0.5 — pushes text further right
                        right: 20,
                        top: heroHeight * 0.20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome\nBack',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: AppColors.cream,
                                fontSize: 28,          // was 32
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Continue your journey toward smarter, '
                              'budget-friendly cooking.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.cream.withValues(alpha: 0.9),
                                fontSize: 13,          // was 13
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ─────────────────────────────────────
                      // APP NAME
                      // ─────────────────────────────────────
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
            // LOGIN CARD
            // ======================================================

            Expanded(
              flex: 50,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  28,
                  30,
                  28,
                  20,
                ),
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
                      // ------------------------------------------------
                      // Title
                      // ------------------------------------------------

                      Text(
                        'Log in',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.burntOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ------------------------------------------------
                      // Email
                      // ------------------------------------------------

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                          ),

                          // Login-specific pill styling
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkInputBackground
                              : AppColors.inputBackground,

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
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ------------------------------------------------
                      // Password
                      // ------------------------------------------------

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        focusNode: _passwordFocusNode,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          hintText: 'Password',

                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                          ),

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

                          // Login-specific pill styling
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkInputBackground
                              : AppColors.inputBackground,

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
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ------------------------------------------------
                      // Forgot Password
                      // ------------------------------------------------

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                           context.push(AppRoutes.resetPassword);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(
                              color: AppColors.olive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------------------------------------------
                      // Login Button
                      // ------------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _login,
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

                      // ------------------------------------------------
                      // Sign Up
                      // ------------------------------------------------

                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Don\'t have an account yet? ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign in',
                                style: const TextStyle(
                                  color: AppColors.olive,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.push(AppRoutes.register);
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
