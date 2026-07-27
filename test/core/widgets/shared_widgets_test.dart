import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopify/core/theme/app_theme.dart';
import 'package:shopify/core/widgets/app_text_field.dart';
import 'package:shopify/core/widgets/brand_app_bar.dart';
import 'package:shopify/core/widgets/primary_button.dart';
import 'package:shopify/core/widgets/secondary_button.dart';

/// يغلّف [child] بثيم التطبيق داخل `Scaffold` لاختباره.
Widget _wrap(Widget child, {TextDirection direction = TextDirection.rtl}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );

void main() {
  group('AppTextField', () {
    testWidgets('يعرض العنوان فوق الحقل ويشغّل الـ validator', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _wrap(
          Form(
            key: formKey,
            child: const AppTextField(
              label: 'البريد الإلكتروني',
              validator: _alwaysInvalid,
            ),
          ),
        ),
      );

      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('قيمة غير صحيحة'), findsOneWidget);
    });

    testWidgets('يبدأ حقل كلمة المرور مخفيًا ويتبدّل بزر الإظهار', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppTextField(label: 'كلمة المرور', isPassword: true)),
      );

      EditableText field() =>
          tester.widget<EditableText>(find.byType(EditableText));

      expect(field().obscureText, isTrue);

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(field().obscureText, isFalse);
    });

    testWidgets('لا يعرض زر الإظهار للحقول العادية', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppTextField(label: 'الاسم')));

      expect(find.byType(IconButton), findsNothing);
    });
  });

  group('PrimaryButton', () {
    testWidgets('يستدعي onPressed في الحالة العادية', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'دخول', onPressed: () => taps++)),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(taps, 1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('يعرض مؤشرًا ويعطّل الضغط عند isLoading', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(
            label: 'دخول',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('دخول'), findsNothing);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(taps, 0);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });
  });

  group('SecondaryButton', () {
    testWidgets('يعرض الأيقونة والنص ويعطّل الضغط عند isLoading', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          SecondaryButton(
            label: 'الدخول بحساب Google',
            icon: Icons.g_mobiledata,
            onPressed: () => taps++,
          ),
        ),
      );

      expect(find.text('الدخول بحساب Google'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);

      await tester.tap(find.byType(SecondaryButton));
      await tester.pump();
      expect(taps, 1);

      await tester.pumpWidget(
        _wrap(
          SecondaryButton(
            label: 'الدخول بحساب Google',
            icon: Icons.g_mobiledata,
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
    });
  });

  group('BrandAppBar', () {
    testWidgets('يعرض ESTUDIO مع تمويه خلفية وبلا زر رجوع افتراضيًا', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            extendBodyBehindAppBar: true,
            appBar: BrandAppBar(),
            body: SizedBox.shrink(),
          ),
        ),
      );

      expect(find.text('ESTUDIO'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(IconButton), findsNothing);
      expect(const BrandAppBar().preferredSize.height, kToolbarHeight);
    });

    testWidgets('يعرض زر الرجوع والإجراءات عند تمريرها', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            appBar: BrandAppBar(
              showBack: true,
              actions: <Widget>[
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(IconButton), findsNWidgets(2));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}

String? _alwaysInvalid(String? value) => 'قيمة غير صحيحة';
