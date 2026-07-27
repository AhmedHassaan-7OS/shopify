import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_dimens.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled = true,
    this.autofillHints,
    this.prefixIcon,
    this.maxLines = 1,
  });

  final String label;

  final TextEditingController? controller;

  final String? hintText;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final bool isPassword;

  final String? Function(String?)? validator;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onFieldSubmitted;

  final FocusNode? focusNode;

  final bool enabled;

  final Iterable<String>? autofillHints;

  final IconData? prefixIcon;

  final int maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.isPassword;

  void _toggleObscured() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppDimens.s8),
          child: Text(
            widget.label,
            style: theme.textTheme.labelLarge,
            textAlign: TextAlign.start,
          ),
        ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          autofillHints: widget.autofillHints,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: widget.enabled ? _toggleObscured : null,
                    tooltip: _obscured
                        ? 'إظهار كلمة المرور'
                        : 'إخفاء كلمة المرور',
                    icon: Icon(
                      _obscured ? Symbols.visibility : Symbols.visibility_off,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
