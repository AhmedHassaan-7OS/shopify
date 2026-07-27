import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_dimens.dart';

/// حقل بحث *غير قابل للكتابة* في الرئيسية: مجرّد سطح قابل للضغط بشكل حقل
/// الإدخال، وضغطه يفتح تاب البحث وينقل التركيز لحقله الحقيقي
/// (Requirement 13.11).
///
/// اختير سطح قابل للضغط بدل `TextField` حقيقي حتى لا تُدار حالة نص مكرّرة في
/// شاشتين ولا تُفتح لوحة المفاتيح على حقل لا يبحث. الشكل من توكنز الثيم فقط:
/// خلفية `surfaceContainerLow` وحواف حقول الإدخال، بلا ألوان مكتوبة يدويًا.
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key, this.hint = searchHint, this.onTap});

  /// النص التلميحي العربي (Requirement 13.1).
  static const String searchHint = 'ابحث عن منتج أو قسم';

  /// ارتفاع الحقل مطابقًا لارتفاع حقل الإدخال في شاشة البحث.
  static const double fieldHeight = 56.0;

  /// النص المعروض داخل الحقل.
  final String hint;

  /// يُستدعى عند الضغط؛ `null` يعطّل الحقل.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Semantics(
      button: true,
      label: hint,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppDimens.brInput,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: fieldHeight,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppDimens.s16,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Symbols.search,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimens.s8),
                  Expanded(
                    child: Text(
                      hint,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
