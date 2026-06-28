import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF00081E);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0A1F44);
  static const onPrimaryContainer = Color(0xFF7687B2);

  static const secondary = Color(0xFF005FAF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF54A0FE);
  static const onSecondaryContainer = Color(0xFF003567);
  static const secondaryFixed = Color(0xFFD4E3FF);
  static const secondaryFixedDim = Color(0xFFA5C8FF);
  static const onSecondaryFixed = Color(0xFF001C3A);
  static const onSecondaryFixedVariant = Color(0xFF004786);

  static const tertiary = Color(0xFF150500);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF391700);
  static const onTertiaryContainer = Color(0xFFB37C59);
  static const tertiaryFixed = Color(0xFFFFDBC7);
  static const tertiaryFixedDim = Color(0xFFF8B992);
  static const onTertiaryFixed = Color(0xFF311300);
  static const onTertiaryFixedVariant = Color(0xFF673C1E);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFFBF8FC);
  static const onBackground = Color(0xFF1B1B1E);
  static const surface = Color(0xFFFBF8FC);
  static const onSurface = Color(0xFF1B1B1E);
  static const surfaceBright = Color(0xFFFBF8FC);
  static const surfaceDim = Color(0xFFDBD9DD);
  static const surfaceVariant = Color(0xFFE4E2E5);
  static const onSurfaceVariant = Color(0xFF44464E);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF5F3F7);
  static const surfaceContainer = Color(0xFFEFEDF1);
  static const surfaceContainerHigh = Color(0xFFE9E7EB);
  static const surfaceContainerHighest = Color(0xFFE4E2E5);

  static const outline = Color(0xFF75777F);
  static const outlineVariant = Color(0xFFC5C6CF);

  static const inverseSurface = Color(0xFF303033);
  static const inverseOnSurface = Color(0xFFF2F0F4);
  static const inversePrimary = Color(0xFFB4C6F4);

  static const primaryFixed = Color(0xFFD9E2FF);
  static const primaryFixedDim = Color(0xFFB4C6F4);
  static const onPrimaryFixed = Color(0xFF041A3F);
  static const onPrimaryFixedVariant = Color(0xFF34466D);

  static const surfaceTint = Color(0xFF4C5E86);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
          letterSpacing: -0.02 * 22,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.primary,
        indicatorColor: AppColors.secondaryContainer.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.05 * 10,
            color: isSelected
                ? AppColors.secondaryContainer
                : AppColors.onPrimary.withValues(alpha: 0.6),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? AppColors.secondaryContainer
                : AppColors.onPrimary.withValues(alpha: 0.6),
          );
        }),
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: const Color(0xFF0A1F44).withValues(alpha: 0.05),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primaryContainer, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: AppColors.outlineVariant,
          fontFamily: 'Inter',
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontFamily: 'Inter',
          fontSize: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 40,
        height: 1.2,
        color: AppColors.onBackground,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.onBackground,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.onBackground,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 40,
        height: 1.2,
        color: AppColors.onBackground,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.onBackground,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.onBackground,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.onBackground,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AppColors.onBackground,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: AppColors.onBackground,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: AppColors.onBackground,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.onBackground,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.onBackground,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.05 * 12,
        height: 1.2,
        color: AppColors.onBackground,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.onBackground,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.onBackground,
      ),
    );
  }
}
