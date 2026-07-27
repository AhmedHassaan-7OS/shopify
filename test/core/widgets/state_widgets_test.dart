import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopify/core/theme/app_theme.dart';
import 'package:shopify/core/widgets/app_empty_view.dart';
import 'package:shopify/core/widgets/app_error_view.dart';
import 'package:shopify/core/widgets/app_network_image.dart';
import 'package:shopify/core/widgets/shimmer_views.dart';

Widget _host(
  Widget child, {
  double width = 390,
  TextDirection dir = TextDirection.rtl,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Directionality(
      textDirection: dir,
      child: Scaffold(
        body: SizedBox(
          width: width,
          child: SingleChildScrollView(child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('AppErrorView', () {
    testWidgets('يعرض الأيقونة والرسالة وزر إعادة المحاولة', (
      WidgetTester tester,
    ) async {
      int retries = 0;
      await tester.pumpWidget(
        _host(
          AppErrorView(
            message: 'تعذّر الاتصال بالخدمة، حاول مرة أخرى.',
            onRetry: () => retries++,
          ),
        ),
      );

      expect(
        find.text('تعذّر الاتصال بالخدمة، حاول مرة أخرى.'),
        findsOneWidget,
      );
      expect(find.byIcon(Symbols.error), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      expect(retries, 1);
    });

    testWidgets('يخفي الزر عندما يكون onRetry فارغًا', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const AppErrorView(message: 'خطأ ما')));

      expect(find.text('خطأ ما'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });

  testWidgets('AppEmptyView يعرض رسالة المستدعي', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(const AppEmptyView(message: 'لا توجد نتائج لـ «حقيبة»')),
    );

    expect(find.text('لا توجد نتائج لـ «حقيبة»'), findsOneWidget);
    expect(find.byIcon(Symbols.inbox), findsOneWidget);
  });

  testWidgets('AppNetworkImage يعرض الأيقونة البديلة عند رابط فارغ', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const SizedBox(height: 120, child: AppNetworkImage(url: '  '))),
    );

    expect(find.byIcon(Symbols.image_not_supported), findsOneWidget);
  });

  group('شبكات الشيمر', () {
    testWidgets('شبكة الأقسام تبني بلاطات بلمعة واحدة', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const CategoriesShimmerGrid(itemCount: 6)));

      expect(find.byType(Shimmer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('شبكة المنتجات بعمودين تحت 600 وثلاثة من 600', (
      WidgetTester tester,
    ) async {
      expect(ShimmerMetrics.productColumnsFor(320), 2);
      expect(ShimmerMetrics.productColumnsFor(599), 2);
      expect(ShimmerMetrics.productColumnsFor(600), 3);
      expect(ShimmerMetrics.productColumnsFor(900), 3);

      for (final double width in <double>[320, 599, 600, 900]) {
        await tester.pumpWidget(
          _host(const ProductsShimmerGrid(itemCount: 6), width: width),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('باقي الهياكل تُبنى بدون تجاوز', (WidgetTester tester) async {
      for (final Widget shimmer in <Widget>[
        const SearchShimmer(),
        const FavoritesShimmerList(),
        const ProfileShimmer(),
      ]) {
        await tester.pumpWidget(_host(shimmer, width: 320));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('النسخ الـ sliver تعمل داخل CustomScrollView', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CustomScrollView(
              slivers: <Widget>[
                CategoriesShimmerGrid.sliver(itemCount: 3),
                ProductsShimmerGrid.sliver(itemCount: 2),
                FavoritesShimmerList.sliver(itemCount: 2),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // الـ slivers خارج الشاشة لا تُبنى، فيكفي التأكد من بناء المرئي منها.
      expect(find.byType(Shimmer), findsAtLeastNWidgets(1));
    });
  });
}
