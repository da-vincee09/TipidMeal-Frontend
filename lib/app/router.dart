import 'package:go_router/go_router.dart';
import 'package:meal_recommendation_app/app/main_shell.dart';
import 'package:meal_recommendation_app/app/page_transitions.dart';
import 'package:meal_recommendation_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:meal_recommendation_app/features/authentication/presentation/screens/register_screen.dart';
import 'package:meal_recommendation_app/features/authentication/presentation/screens/reset_password_screen.dart';
import 'package:meal_recommendation_app/features/authentication/presentation/screens/splash_screen.dart';
import 'package:meal_recommendation_app/features/grocery_list/presentation/screens/grocery_list_screen.dart';
import 'package:meal_recommendation_app/features/home/presentation/screens/home_screen.dart';
import 'package:meal_recommendation_app/features/meal_planner/data/models/meal_plan_entry_model.dart';
import 'package:meal_recommendation_app/features/meal_planner/presentation/screens/add_edit_meal_plan_entry_screen.dart';
import 'package:meal_recommendation_app/features/meals/presentation/screens/meal_detail_screen.dart';
import 'package:meal_recommendation_app/features/meals/presentation/screens/meals_screen.dart';
import 'package:meal_recommendation_app/features/pantry/presentation/screens/pantry_screen.dart';
import 'package:meal_recommendation_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:meal_recommendation_app/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:meal_recommendation_app/features/recommendations/presentation/screens/recommendations_screen.dart';
import 'package:meal_recommendation_app/features/meal_planner/presentation/screens/meal_planner_screen.dart';
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


    GoRoute(
      path: AppRoutes.groceryList,
      name: 'groceryList',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return GroceryListScreen(
          startDate: extra?['startDate'] as DateTime?,
          endDate: extra?['endDate'] as DateTime?,
        );
      },
    ),

    // ------------------------------------------------------------
    // Bottom-nav tabs — each branch keeps its own navigation stack.
    // ------------------------------------------------------------
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
            branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
           GoRoute(
              path: '/meals',
              builder: (context, state) => const MealsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final mealId = state.pathParameters['id']!;
                    return MealDetailScreen(mealId: mealId);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.mealPlanner,
              name: 'mealPlanner',
              builder: (context, state) => const MealPlannerScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return AddEditMealPlanEntryScreen(
                      initialDate: extra?['date'] as DateTime?,
                      existingEntry: extra?['entry'] as MealPlanEntryModel?,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.recommendations,
              name: 'recommendations',
              builder: (context, state) => const RecommendationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.pantry,
              name: 'pantry',
              builder: (context, state) => const PantryScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);