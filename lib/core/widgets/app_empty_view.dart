import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_dimens.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.message,
    this.icon = Symbols.inbox,
    this.action,
    this.padding = const EdgeInsetsDirectional.symmetric(
      horizontal: AppDimens.s24,
      vertical: AppDimens.s32,
    ),
  });

  final String message;

  final IconData icon;

  final Widget? action;

  final EdgeInsetsDirectional padding;

  static Widget sliver({
    required String message,
    IconData icon = Symbols.inbox,
    Widget? action,
  }) => SliverFillRemaining(
    hasScrollBody: false,
    child: AppEmptyView(message: message, icon: icon, action: action),
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: AppDimens.s48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimens.s16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: AppDimens.s24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
