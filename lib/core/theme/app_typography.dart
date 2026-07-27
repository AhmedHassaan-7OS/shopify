import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Inter';

  static const double lsDisplayLarge = -0.96;

  static const double lsHeadlineLarge = -0.32;

  static const double lsTitleLarge = -0.28;

  static const double lsLabelLarge = 0.7;

  static TextTheme textTheme(Color color) => TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 48,
      height: 56 / 48,
      fontWeight: FontWeight.w700,
      letterSpacing: lsDisplayLarge,
      color: color,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w600,
      letterSpacing: lsHeadlineLarge,
      color: color,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w600,
      color: color,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w600,
      letterSpacing: lsTitleLarge,
      color: color,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 18,
      height: 28 / 18,
      fontWeight: FontWeight.w400,
      color: color,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      color: color,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
      letterSpacing: lsLabelLarge,
      color: color,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w500,
      color: color,
    ),
  );

  static TextTheme get light => textTheme(AppColors.lightOnSurface);

  static TextTheme get dark => textTheme(AppColors.darkOnSurface);

  static TextTheme of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
