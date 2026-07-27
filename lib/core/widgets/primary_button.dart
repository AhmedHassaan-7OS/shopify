import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

const double _kIndicatorStrokeWidth = 2.0;

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;

  final VoidCallback? onPressed;

  final bool isLoading;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color foreground = theme.colorScheme.onPrimary;

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? _ButtonProgress(color: foreground)
          : _ButtonLabel(label: label, icon: icon),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Text text = Text(label, textAlign: TextAlign.center);
    if (icon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: AppDimens.s8),
        text,
      ],
    );
  }
}

class _ButtonProgress extends StatelessWidget {
  const _ButtonProgress({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final double stroke =
        Theme.of(context).progressIndicatorTheme.strokeWidth ??
        _kIndicatorStrokeWidth;

    return Semantics(
      label: 'جارٍ التحميل',
      child: SizedBox.square(
        dimension: AppDimens.s24,
        child: CircularProgressIndicator(strokeWidth: stroke, color: color),
      ),
    );
  }
}
