import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopify/core/errors/failure.dart';
import 'package:shopify/core/theme/app_theme.dart';
import 'package:shopify/core/widgets/app_empty_view.dart';
import 'package:shopify/core/widgets/app_error_view.dart';
import 'package:shopify/core/widgets/rating_stars.dart';
import 'package:shopify/core/widgets/shimmer_views.dart';
import 'package:shopify/data/models/category_model.dart';
import 'package:shopify/data/models/product_model.dart';
import 'package:shopify/data/models/products_response_model.dart';
import 'package:shopify/data/repositories/catalog_repository.dart';
import 'package:shopify/data/repositories/favorites_repository.dart';
import 'package:shopify/data/services/auth_service.dart';
import 'package:shopify/logic/favorites/favorites_cubit.dart';
import 'package:shopify/presentation/products/product_details_screen.dart';
import 'package:shopify/presentation/products/products_screen.dart';
import 'package:shopify/presentation/products/widgets/bento_info_grid.dart';
import 'package:shopify/presentation/products/widgets/product_card.dart';
import 'package:shopify/presentation/products/widgets/product_gallery.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockAuthService extends Mock implements AuthService {}

class _MockUser extends Mock implements User {}

const CategoryModel _category = CategoryModel(
  slug: 'smartphones',
  name: 'هواتف ذكية',
  url: 'https://dummyjson.com/products/category/smartphones',
);

/// الروابط فارغة عن قصد: `AppNetworkImage` يعرض الأيقونة البديلة بلا أي طلب
/// شبكة، فتبقى الاختبارات نقيّة وسريعة.
ProductModel _product(int id, {List<String> images = const <String>[]}) =>
    ProductModel(
      id: id,
      title: 'منتج رقم $id بعنوان طويل نسبيًا لاختبار التخطيط',
      description: 'وصف كامل للمنتج رقم $id',
      category: 'smartphones',
      price: 999.9,
      rating: 4.66,
      thumbnail: '',
      images: images,
      brand: 'Apple',
      stock: 12,
    );

ProductsResponseModel _response(List<ProductModel> products) =>
    ProductsResponseModel(
      products: products,
      total: products.length,
      skip: 0,
      limit: products.length,
    );

void main() {
  late _MockCatalogRepository catalog;
  late FavoritesCubit favorites;

  setUp(() {
    catalog = _MockCatalogRepository();

    final _MockAuthService auth = _MockAuthService();
    final _MockUser user = _MockUser();
    when(() => user.uid).thenReturn('uid-1');
    when(() => auth.currentUser).thenReturn(user);
    favorites = FavoritesCubit(
      favoritesRepository: FavoritesRepository(
        firestore: FakeFirebaseFirestore(),
      ),
      authService: auth,
    );
  });

  tearDown(() => favorites.close());

  // المفضّلة تُوفَّر فوق `MaterialApp` كما في `app.dart`، فتظل متاحة للمسارات
  // المدفوعة فوق الشاشة الأولى.
  Widget host(Widget child) => BlocProvider<FavoritesCubit>.value(
    value: favorites,
    child: MaterialApp(
      theme: AppTheme.light,
      home: Directionality(textDirection: TextDirection.rtl, child: child),
    ),
  );

  Future<void> resize(WidgetTester tester, double width) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('ProductsScreen', () {
    testWidgets('يعرض شيمر أثناء التحميل ثم عنوان القسم وكل الكروت', (
      WidgetTester tester,
    ) async {
      when(() => catalog.getProductsByCategory('smartphones')).thenAnswer(
        (_) async =>
            _response(<ProductModel>[for (int i = 1; i <= 5; i++) _product(i)]),
      );

      await tester.pumpWidget(
        host(ProductsScreen(category: _category, catalogRepository: catalog)),
      );

      expect(find.byType(ProductsShimmerGrid), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text(_category.name), findsOneWidget);
      // الشبكة كسولة، فتُبنى الكروت الظاهرة فقط في المنفذ الحالي.
      expect(find.byType(ProductCard), findsAtLeastNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    for (final double width in <double>[320, 599, 600, 900]) {
      testWidgets('يبني الشبكة بلا تجاوز على عرض $width', (
        WidgetTester tester,
      ) async {
        await resize(tester, width);
        when(() => catalog.getProductsByCategory('smartphones')).thenAnswer(
          (_) async => _response(<ProductModel>[
            for (int i = 1; i <= 6; i++) _product(i),
          ]),
        );

        await tester.pumpWidget(
          host(ProductsScreen(category: _category, catalogRepository: catalog)),
        );
        await tester.pumpAndSettle();

        final SliverGridDelegateWithFixedCrossAxisCount delegate =
            tester.widget<SliverGrid>(find.byType(SliverGrid)).gridDelegate
                as SliverGridDelegateWithFixedCrossAxisCount;

        expect(delegate.crossAxisCount, width >= 600 ? 3 : 2);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('يعرض حالة الفراغ العربية عند صفر منتجات', (
      WidgetTester tester,
    ) async {
      when(
        () => catalog.getProductsByCategory('smartphones'),
      ).thenAnswer((_) async => _response(const <ProductModel>[]));

      await tester.pumpWidget(
        host(ProductsScreen(category: _category, catalogRepository: catalog)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('لا توجد منتجات في هذا القسم حاليًا.'), findsOneWidget);
    });

    testWidgets('يعرض الخطأ وزر إعادة المحاولة يكرّر الطلب', (
      WidgetTester tester,
    ) async {
      when(
        () => catalog.getProductsByCategory('smartphones'),
      ).thenThrow(const Failure('تعذّر الاتصال بالخدمة.'));

      await tester.pumpWidget(
        host(ProductsScreen(category: _category, catalogRepository: catalog)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('تعذّر الاتصال بالخدمة.'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      verify(() => catalog.getProductsByCategory('smartphones')).called(2);
    });

    testWidgets('الضغط على كارت يفتح شاشة التفاصيل بنفس المنتج', (
      WidgetTester tester,
    ) async {
      final ProductModel product = _product(3);
      when(
        () => catalog.getProductsByCategory('smartphones'),
      ).thenAnswer((_) async => _response(<ProductModel>[product]));

      await tester.pumpWidget(
        host(ProductsScreen(category: _category, catalogRepository: catalog)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ProductCard));
      await tester.pumpAndSettle();

      final ProductDetailsScreen details = tester.widget<ProductDetailsScreen>(
        find.byType(ProductDetailsScreen),
      );
      expect(details.product, product);
    });
  });

  group('ProductGallery', () {
    test('يعتمد الصور عند وجودها ويرجع إلى thumbnail عند فراغها', () {
      expect(
        ProductGallery.imagesOf(_product(1, images: <String>['a', 'b'])),
        <String>['a', 'b'],
      );
      expect(ProductGallery.showsIndicator(_product(1)), isFalse);
      expect(
        ProductGallery.showsIndicator(_product(1, images: <String>['a'])),
        isFalse,
      );
      expect(
        ProductGallery.showsIndicator(_product(1, images: <String>['a', 'b'])),
        isTrue,
      );
    });

    testWidgets('عدد الصفحات والنقاط يساوي طول images عند تعدّد الصور', (
      WidgetTester tester,
    ) async {
      // ثلاثة روابط فارغة: نفس الطول بلا أي طلب شبكة.
      final ProductModel product = _product(
        1,
        images: const <String>['', '', ''],
      );

      await tester.pumpWidget(
        host(
          Scaffold(
            body: SingleChildScrollView(
              child: ProductGallery(product: product),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<PageView>(find.byType(PageView))
            .childrenDelegate
            .estimatedChildCount,
        3,
      );
      expect(
        find.descendant(
          of: find.byType(Wrap),
          matching: find.byType(Container),
        ),
        findsNWidgets(3),
      );
    });
  });

  group('BentoInfoGrid', () {
    test('يستبدل brand الفارغ بالـ category', () {
      const ProductModel noBrand = ProductModel(
        id: 1,
        title: 't',
        description: 'd',
        category: 'smartphones',
        price: 1,
        rating: 1,
        thumbnail: '',
        images: <String>[],
        brand: '  ',
        stock: 3,
      );

      expect(BentoInfoGrid.brandValueOf(noBrand), 'smartphones');
      expect(BentoInfoGrid.brandValueOf(_product(1)), 'Apple');
      expect(BentoInfoGrid.stockValueOf(_product(1)), '12');
    });
  });

  group('ProductDetailsScreen', () {
    testWidgets('يعرض العنوان والسعر والتقييم والوصف وخلايا المعلومات', (
      WidgetTester tester,
    ) async {
      final ProductModel product = _product(9);

      await tester.pumpWidget(host(ProductDetailsScreen(product: product)));
      await tester.pumpAndSettle();

      expect(find.text(product.title), findsOneWidget);
      expect(find.text(r'$999.90'), findsOneWidget);
      expect(find.byType(RatingStars), findsOneWidget);
      expect(find.text('4.7'), findsOneWidget);
      expect(find.text(product.description), findsOneWidget);
      expect(find.byType(BentoInfoGrid), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final double width in <double>[320, 900]) {
      testWidgets('تُبنى الشاشة بلا تجاوز على عرض $width', (
        WidgetTester tester,
      ) async {
        await resize(tester, width);

        await tester.pumpWidget(
          host(ProductDetailsScreen(product: _product(4))),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('الزر الثابت أسفل الشاشة يبدّل المفضّلة ويغيّر نصّه', (
      WidgetTester tester,
    ) async {
      final ProductModel product = _product(9);

      await tester.pumpWidget(host(ProductDetailsScreen(product: product)));
      await tester.pumpAndSettle();

      expect(find.text(ProductDetailsScreen.addLabel), findsOneWidget);

      await tester.tap(find.text(ProductDetailsScreen.addLabel));
      await tester.pump();

      expect(favorites.isFavorite(product.id), isTrue);
      expect(find.text(ProductDetailsScreen.removeLabel), findsOneWidget);
    });
  });
}
