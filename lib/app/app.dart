import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/app/router.dart';
import 'package:meal_recommendation_app/app/theme.dart';
import 'package:meal_recommendation_app/core/providers/theme_mode_provider.dart';

class TipidMealApp extends ConsumerWidget {
  const TipidMealApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'TipidMeal',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      routerConfig: appRouter,
    );
  }
}