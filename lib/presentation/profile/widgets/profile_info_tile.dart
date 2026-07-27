import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  static const String emptyValuePlaceholder = '—';

  final IconData icon;

  final String label;

  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String displayValue = value.trim().isEmpty
        ? emptyValuePlaceholder
        : value;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppDimens.s16,
        vertical: AppDimens.s16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: AppDimens.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimens.s8 / 2),
                Text(
                  displayValue,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
