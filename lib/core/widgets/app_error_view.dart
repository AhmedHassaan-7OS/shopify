import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_dimens.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Symbols.error,
    this.retryLabel = 'إعادة المحاولة',
    this.padding = const EdgeInsetsDirectional.symmetric(
      horizontal: AppDimens.s24,
      vertical: AppDimens.s32,
    ),
  });

  final String message;

  final VoidCallback? onRetry;

  final IconData icon;

  final String retryLabel;

  final EdgeInsetsDirectional padding;

  static Widget sliver({
    required String message,
    VoidCallback? onRetry,
    IconData icon = Symbols.error,
    String retryLabel = 'إعادة المحاولة',
  }) => SliverFillRemaining(
    hasScrollBody: false,
    child: AppErrorView(
      message: message,
      onRetry: onRetry,
      icon: icon,
      retryLabel: retryLabel,
    ),
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
            Icon(icon, size: AppDimens.s48, color: theme.colorScheme.error),
            const SizedBox(height: AppDimens.s16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppDimens.s24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Symbols.refresh),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
