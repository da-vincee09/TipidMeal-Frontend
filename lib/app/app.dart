import 'package:flutter/material.dart';
import 'package:meal_recommendation_app/app/router.dart';
import 'package:meal_recommendation_app/app/theme.dart';

class TipidMealApp extends StatelessWidget {
  const TipidMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TipidMeal',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      routerConfig: appRouter,
    );
  }
}