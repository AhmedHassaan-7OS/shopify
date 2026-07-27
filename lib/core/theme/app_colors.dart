import 'package:flutter/material.dart';

@immutable
class AppColorTokens {
  const AppColorTokens({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.productCardSurface,
  });

  final Brightness brightness;

  final Color primary;

  final Color onPrimary;

  final Color secondary;

  final Color surface;

  final Color surfaceContainerLowest;

  final Color surfaceContainerLow;

  final Color surfaceContainer;

  final Color surfaceContainerHighest;

  final Color onSurface;

  final Color onSurfaceVariant;

  final Color outline;

  final Color outlineVariant;

  final Color error;

  final Color onError;

  final Color productCardSurface;
}

class AppColors {
  const AppColors._();

  static const Color lightPrimary = Color(0xFF000000);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFF5D5F5F);
  static const Color lightSurface = Color(0xFFF9F9F9);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF3F3F3);
  static const Color lightSurfaceContainer = Color(0xFFEEEEEE);
  static const Color lightSurfaceContainerHighest = Color(0xFFE2E2E2);
  static const Color lightOnSurface = Color(0xFF1B1B1B);
  static const Color lightOnSurfaceVariant = Color(0xFF4C4546);
  static const Color lightOutline = Color(0xFF7E7576);
  static const Color lightOutlineVariant = Color(0xFFCFC4C5);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightProductCardSurface = Color(0xFFF5F5F7);

  static const Color darkPrimary = Color(0xFFFFFFFF);
  static const Color darkOnPrimary = Color(0xFF1B1B1B);
  static const Color darkSecondary = Color(0xFFC6C6C7);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color darkSurfaceContainerLow = Color(0xFF1B1B1B);
  static const Color darkSurfaceContainer = Color(0xFF232323);
  static const Color darkSurfaceContainerHighest = Color(0xFF303030);
  static const Color darkOnSurface = Color(0xFFF1F1F1);
  static const Color darkOnSurfaceVariant = Color(0xFFCFC4C5);
  static const Color darkOutline = Color(0xFF9A9192);
  static const Color darkOutlineVariant = Color(0xFF3A3536);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkProductCardSurface = Color(0xFF1E1E1E);

  static const AppColorTokens light = AppColorTokens(
    brightness: Brightness.light,
    primary: lightPrimary,
    onPrimary: lightOnPrimary,
    secondary: lightSecondary,
    surface: lightSurface,
    surfaceContainerLowest: lightSurfaceContainerLowest,
    surfaceContainerLow: lightSurfaceContainerLow,
    surfaceContainer: lightSurfaceContainer,
    surfaceContainerHighest: lightSurfaceContainerHighest,
    onSurface: lightOnSurface,
    onSurfaceVariant: lightOnSurfaceVariant,
    outline: lightOutline,
    outlineVariant: lightOutlineVariant,
    error: lightError,
    onError: lightOnError,
    productCardSurface: lightProductCardSurface,
  );

  static const AppColorTokens dark = AppColorTokens(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    secondary: darkSecondary,
    surface: darkSurface,
    surfaceContainerLowest: darkSurfaceContainerLowest,
    surfaceContainerLow: darkSurfaceContainerLow,
    surfaceContainer: darkSurfaceContainer,
    surfaceContainerHighest: darkSurfaceContainerHighest,
    onSurface: darkOnSurface,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    error: darkError,
    onError: darkOnError,
    productCardSurface: darkProductCardSurface,
  );

  static AppColorTokens of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static Color productCardSurfaceOf(BuildContext context) =>
      of(Theme.of(context).brightness).productCardSurface;
}
