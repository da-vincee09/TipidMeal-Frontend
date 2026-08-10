import 'package:go_router/go_router.dart';
import 'package:meal_recommendation_app/app/page_transitions.dart';
import 'package:meal_recommendation_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:meal_recommendation_app/features/authentication/presentation/screens/register_screen.dart';
import 'package:meal_recommendation_app/features/authentication/presentation/screens/reset_password_screen.dart';
import 'package:meal_recommendation_app/features/authentication/presentation/screens/splash_screen.dart';
import 'package:meal_recommendation_app/features/home/presentation/screens/home_screen.dart';
import 'package:meal_recommendation_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:meal_recommendation_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      pageBuilder: (context, state) => buildPageWithTransition(
        context: context,
        state: state,
        type: TransitionType.fade,
        child: const SplashScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (context, state) => buildPageWithTransition(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      pageBuilder: (context, state) => buildPageWithTransition(
        context: context,
        state: state,
        child: const RegisterScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.resetPassword,
      name: 'resetPassword',
      pageBuilder: (context, state) => buildPageWithTransition(
        context: context,
        state: state,
        child: const ResetPasswordScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) => buildPageWithTransition(
        context: context,
        state: state,
        type: TransitionType.fade,
        child: const HomeScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.profileSetup,
      name: 'profileSetup',
      pageBuilder: (context, state) => buildPageWithTransition(
        context: context,
        state: state,
        child: const ProfileSetupScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      pageBuilder: (context, state) => buildPageWithTransition(
        context: context,
        state: state,
        child: const ProfileScreen(),
      ),
    ),
  ],
);