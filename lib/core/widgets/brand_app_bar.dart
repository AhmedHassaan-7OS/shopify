import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({
    super.key,
    this.title = brandTitle,
    this.actions,
    this.showBack = false,
  });

  static const String brandTitle = 'Shopify';
  static const double blurSigma = 12.0;

  static IconData backIconOf(TextDirection direction) =>
      direction == TextDirection.rtl
      ? Symbols.arrow_forward_ios
      : Symbols.arrow_back_ios_new;

  final String title;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background =
        theme.appBarTheme.backgroundColor ??
        theme.colorScheme.surface.withValues(alpha: 0.8);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: AppBar(
          backgroundColor: background,
          automaticallyImplyLeading: false,
          leading: showBack
              ? IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: Icon(backIconOf(Directionality.of(context))),
                )
              : null,
          title: Text(title, style: theme.appBarTheme.titleTextStyle),
          actions: actions,
        ),
      ),
    );
  }
}
