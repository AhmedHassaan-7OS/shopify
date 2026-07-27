import 'package:flutter/material.dart';

class AppDimens {
  const AppDimens._();

  static const double s8 = 8.0;

  static const double s12 = 12.0;

  static const double s16 = 16.0;

  static const double s24 = 24.0;

  static const double s32 = 32.0;

  static const double s48 = 48.0;

  static const List<double> spacingScale = <double>[s8, s16, s24, s32, s48];

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: s24);

  static const EdgeInsetsDirectional screenPaddingDirectional =
      EdgeInsetsDirectional.symmetric(horizontal: s24);

  static const double rInput = 12.0;

  static const double rCard = 16.0;

  static const double rFeature = 24.0;

  static const BorderRadius brInput = BorderRadius.all(Radius.circular(rInput));

  static const BorderRadius brCard = BorderRadius.all(Radius.circular(rCard));

  static const BorderRadius brFeature = BorderRadius.all(
    Radius.circular(rFeature),
  );

  static const double buttonHeight = 56.0;

  static const double navBarHeight = 80.0;

  static const double avatarSize = 128.0;

  static const double productImageAspectRatio = 4 / 5;

  static const Color shadowColor = Color(0x0A000000);

  static const List<BoxShadow> softShadow = <BoxShadow>[
    BoxShadow(offset: Offset(0, s8), blurRadius: 24.0, color: shadowColor),
  ];
}
