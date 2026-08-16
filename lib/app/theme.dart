import 'package:flutter/material.dart';
import 'package:meal_recommendation_app/app/colors.dart';

abstract final class AppTheme {
  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.burntOrange,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.burntOrange,
      onPrimary: Colors.white,

      secondary: AppColors.olive,
      onSecondary: Colors.white,

      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,

      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.lightBackground,

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      // ----------------------------------------------------------
      // TEXT
      // ----------------------------------------------------------

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.lightText,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.lightText,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.lightText,
        ),

        headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.lightText,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.lightText,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.lightText,
        ),

        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.lightText,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.lightText,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.lightText,
        ),

        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          color: AppColors.lightText,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          color: AppColors.lightText,
        ),
        bodySmall: TextStyle(
          fontWeight: FontWeight.w400,
          color: AppColors.lightSecondaryText,
        ),

        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),

      // ----------------------------------------------------------
      // INPUT FIELDS
      // ----------------------------------------------------------

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),

        hintStyle: const TextStyle(
          color: AppColors.lightSecondaryText,
          fontWeight: FontWeight.w400,
        ),

        labelStyle: const TextStyle(
          color: AppColors.lightSecondaryText,
          fontWeight: FontWeight.w400,
        ),

        prefixIconColor: AppColors.lightSecondaryText,
        suffixIconColor: AppColors.lightSecondaryText,

        // Pill shape
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

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // ELEVATED BUTTON
      // ----------------------------------------------------------

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burntOrange,
          foregroundColor: Colors.white,

          minimumSize: const Size.fromHeight(52),

          elevation: 0,

          shape: const StadiumBorder(),

          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // OUTLINED BUTTON
      // ----------------------------------------------------------

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.burntOrange,

          minimumSize: const Size.fromHeight(52),

          side: const BorderSide(
            color: AppColors.burntOrange,
            width: 1.5,
          ),

          shape: const StadiumBorder(),

          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // TEXT BUTTON
      // ----------------------------------------------------------

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.olive,

          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // CARD
      // ----------------------------------------------------------

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ----------------------------------------------------------
      // DIVIDER
      // ----------------------------------------------------------

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
      ),


      // ----------------------------------------------------------
      // NAVIGATION BAR
      // ----------------------------------------------------------

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.burntOrange.withValues(alpha: 0.15),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.burntOrange : AppColors.lightSecondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.burntOrange : AppColors.lightSecondaryText,
          );
        }),
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.burntOrange,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.burntOrange,
      onPrimary: Colors.white,

      secondary: AppColors.olive,
      onSecondary: Colors.white,

      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,

      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.darkBackground,

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      // ----------------------------------------------------------
      // TEXT
      // ----------------------------------------------------------

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),

        headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),

        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
        ),

        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          color: AppColors.darkText,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          color: AppColors.darkText,
        ),
        bodySmall: TextStyle(
          fontWeight: FontWeight.w400,
          color: AppColors.darkSecondaryText,
        ),

        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),

      // ----------------------------------------------------------
      // INPUT FIELDS
      // ----------------------------------------------------------

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBackground,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),

        hintStyle: const TextStyle(
          color: AppColors.darkSecondaryText,
          fontWeight: FontWeight.w400,
        ),

        labelStyle: const TextStyle(
          color: AppColors.darkSecondaryText,
          fontWeight: FontWeight.w400,
        ),

        prefixIconColor: AppColors.darkSecondaryText,
        suffixIconColor: AppColors.darkSecondaryText,

        // Pill shape
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

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // ELEVATED BUTTON
      // ----------------------------------------------------------

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burntOrange,
          foregroundColor: Colors.white,

          minimumSize: const Size.fromHeight(52),

          elevation: 0,

          shape: const StadiumBorder(),

          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // OUTLINED BUTTON
      // ----------------------------------------------------------

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.burntOrange,

          minimumSize: const Size.fromHeight(52),

          side: const BorderSide(
            color: AppColors.burntOrange,
            width: 1.5,
          ),

          shape: const StadiumBorder(),

          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // TEXT BUTTON
      // ----------------------------------------------------------

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.olive,

          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // CARD
      // ----------------------------------------------------------

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ----------------------------------------------------------
      // DIVIDER
      // ----------------------------------------------------------

      dividerTheme: const DividerThemeData(
        color: Color(0xFF374151),
        thickness: 1,
      ),

      // ----------------------------------------------------------
      // NAVIGATION BAR
      // ----------------------------------------------------------

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.burntOrange.withValues(alpha: 0.2),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.burntOrange : AppColors.darkSecondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.burntOrange : AppColors.darkSecondaryText,
          );
        }),
      ),
    );
  }
}

