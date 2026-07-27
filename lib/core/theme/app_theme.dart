import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(AppColors.light);

  static ThemeData get dark => _build(AppColors.dark);

  static ThemeData of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static ColorScheme colorSchemeFrom(AppColorTokens t) => ColorScheme(
    brightness: t.brightness,
    primary: t.primary,
    onPrimary: t.onPrimary,
    primaryContainer: t.primary,
    onPrimaryContainer: t.onPrimary,
    secondary: t.secondary,
    onSecondary: t.onPrimary,
    secondaryContainer: t.surfaceContainer,
    onSecondaryContainer: t.onSurface,
    tertiary: t.secondary,
    onTertiary: t.onPrimary,
    error: t.error,
    onError: t.onError,
    surface: t.surface,
    onSurface: t.onSurface,
    surfaceContainerLowest: t.surfaceContainerLowest,
    surfaceContainerLow: t.surfaceContainerLow,
    surfaceContainer: t.surfaceContainer,
    surfaceContainerHigh: t.surfaceContainer,
    surfaceContainerHighest: t.surfaceContainerHighest,
    onSurfaceVariant: t.onSurfaceVariant,
    outline: t.outline,
    outlineVariant: t.outlineVariant,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: t.onSurface,
    onInverseSurface: t.surface,
    inversePrimary: t.onPrimary,
    surfaceTint: Colors.transparent,
  );

  static ThemeData _build(AppColorTokens t) {
    final ColorScheme scheme = colorSchemeFrom(t);
    final TextTheme text = AppTypography.textTheme(t.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: t.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: t.surface,
      canvasColor: t.surface,
      shadowColor: AppDimens.shadowColor,
      splashFactory: InkSparkle.splashFactory,
      fontFamily: AppTypography.fontFamily,
      textTheme: text,
      primaryTextTheme: text,
      appBarTheme: _appBarTheme(t, text),
      filledButtonTheme: _filledButtonTheme(t, text),
      outlinedButtonTheme: _outlinedButtonTheme(t, text),
      textButtonTheme: _textButtonTheme(t, text),
      inputDecorationTheme: _inputDecorationTheme(t, text),
      cardTheme: _cardTheme(t),
      chipTheme: _chipTheme(t, text),
      navigationBarTheme: _navigationBarTheme(t, text),
      dividerTheme: DividerThemeData(
        color: t.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: t.onSurface, size: 24),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.onSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: t.surface),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppDimens.brInput),
      ),
    );
  }

  static AppBarThemeData _appBarTheme(AppColorTokens t, TextTheme text) =>
      AppBarThemeData(
        backgroundColor: t.surface.withValues(alpha: 0.8),
        foregroundColor: t.onSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: t.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: t.onSurface, size: 24),
      );

  static FilledButtonThemeData _filledButtonTheme(
    AppColorTokens t,
    TextTheme text,
  ) => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: t.primary,
      foregroundColor: t.onPrimary,
      disabledBackgroundColor: t.surfaceContainerHighest,
      disabledForegroundColor: t.onSurfaceVariant,
      minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.s24),
      elevation: 0,
      textStyle: text.labelLarge,
      shape: const RoundedRectangleBorder(borderRadius: AppDimens.brCard),
    ),
  );

  static OutlinedButtonThemeData _outlinedButtonTheme(
    AppColorTokens t,
    TextTheme text,
  ) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: t.primary,
      disabledForegroundColor: t.onSurfaceVariant,
      minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.s24),
      side: BorderSide(color: t.primary, width: 1.5),
      textStyle: text.labelLarge,
      shape: const RoundedRectangleBorder(borderRadius: AppDimens.brCard),
    ),
  );

  static TextButtonThemeData _textButtonTheme(
    AppColorTokens t,
    TextTheme text,
  ) => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: t.primary,
      disabledForegroundColor: t.onSurfaceVariant,
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.s8,
        vertical: AppDimens.s8,
      ),
      textStyle: text.labelLarge?.copyWith(
        decoration: TextDecoration.underline,
        decorationThickness: 1,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppDimens.brInput),
    ),
  );

  static InputDecorationThemeData _inputDecorationTheme(
    AppColorTokens t,
    TextTheme text,
  ) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: AppDimens.brInput,
      borderSide: BorderSide(color: color, width: width),
    );

    return InputDecorationThemeData(
      filled: true,
      fillColor: t.surfaceContainerLowest,
      contentPadding: const EdgeInsets.all(AppDimens.s16),
      border: border(t.outlineVariant, 1),
      enabledBorder: border(t.outlineVariant, 1),
      disabledBorder: border(t.outlineVariant, 1),
      focusedBorder: border(t.primary, 1.5),
      errorBorder: border(t.error, 1),
      focusedErrorBorder: border(t.error, 1.5),
      hintStyle: text.bodyMedium?.copyWith(color: t.onSurfaceVariant),
      labelStyle: text.bodyMedium?.copyWith(color: t.onSurfaceVariant),
      floatingLabelStyle: text.labelLarge?.copyWith(color: t.primary),
      errorStyle: text.labelMedium?.copyWith(color: t.error),
      prefixIconColor: t.onSurfaceVariant,
      suffixIconColor: t.onSurfaceVariant,
    );
  }

  static CardThemeData _cardTheme(AppColorTokens t) => CardThemeData(
    color: t.surfaceContainerLowest,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppDimens.shadowColor,
    elevation: 0,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(borderRadius: AppDimens.brCard),
  );

  static ChipThemeData _chipTheme(AppColorTokens t, TextTheme text) =>
      ChipThemeData(
        backgroundColor: t.surfaceContainerLowest,
        selectedColor: t.primary,
        disabledColor: t.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        checkmarkColor: t.onPrimary,
        showCheckmark: false,
        side: BorderSide(color: t.outlineVariant),
        shape: const StadiumBorder(),
        labelStyle: text.labelLarge?.copyWith(color: t.onSurface),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: t.onPrimary),
        labelPadding: const EdgeInsets.symmetric(horizontal: AppDimens.s8),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.s8,
          vertical: 10,
        ),
        elevation: 0,
        pressElevation: 0,
      );

  static NavigationBarThemeData _navigationBarTheme(
    AppColorTokens t,
    TextTheme text,
  ) => NavigationBarThemeData(
    height: AppDimens.navBarHeight,
    backgroundColor: t.surface.withValues(alpha: 0.9),
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
    indicatorColor: Colors.transparent,
    indicatorShape: const StadiumBorder(),
    elevation: 0,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    labelTextStyle: WidgetStateProperty.all(text.labelMedium),
    iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final bool selected = states.contains(WidgetState.selected);
      return IconThemeData(
        size: selected ? 26 : 24,
        color: selected ? t.primary : t.onSurfaceVariant,
      );
    }),
  );
}
