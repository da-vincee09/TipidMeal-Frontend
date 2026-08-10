import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_recommendation_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/app/routes.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    // Post-frame so the first build completes before we possibly
    // navigate away — avoids "navigation during build" issues.
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveDestination());
  }

  Future<void> _resolveDestination() async {
    setState(() => _error = null);

    // A brief, deliberate pause so the splash branding is actually seen,
    // even on a fast/cached session check. Not required for correctness.
    await Future.delayed(const Duration(milliseconds: 600));

    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session == null) {
      context.go(AppRoutes.login);
      return;
    }

    // Session exists — figure out whether this user has a profile yet.
    await ref.read(profileControllerProvider.notifier).loadProfile();

    if (!mounted) return;

    final profileState = ref.read(profileControllerProvider);

    profileState.when(
      data: (profile) {
        if (profile == null) {
          context.go(AppRoutes.profileSetup);
        } else {
          context.go(AppRoutes.home);
        }
      },
      loading: () {
        // Shouldn't happen — we awaited loadProfile() above — but guard
        // anyway rather than leaving the user stuck on a blank splash.
        setState(() => _error = 'Taking longer than expected.');
      },
      error: (error, _) {
        setState(() => _error = 'Could not connect. Please check your '
            'connection and try again.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 52,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'TipidMeal',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Affordable meals. Smarter choices.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 40),

            if (_error == null)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.orange,
                ),
              )
            else ...[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _resolveDestination,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}