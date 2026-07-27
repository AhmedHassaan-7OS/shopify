import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopify/core/errors/failure.dart';
import 'package:shopify/core/theme/app_theme.dart';
import 'package:shopify/core/widgets/app_empty_view.dart';
import 'package:shopify/core/widgets/app_error_view.dart';
import 'package:shopify/core/widgets/shimmer_views.dart';
import 'package:shopify/data/models/category_model.dart';
import 'package:shopify/data/models/product_model.dart';
import 'package:shopify/data/models/products_response_model.dart';
import 'package:shopify/data/repositories/catalog_repository.dart';
import 'package:shopify/logic/categories/categories_cubit.dart';
import 'package:shopify/logic/search/search_cubit.dart';
import 'package:shopify/logic/search/search_state.dart';
import 'package:shopify/presentation/home/home_screen.dart';
import 'package:shopify/presentation/home/widgets/category_tile.dart';
import 'package:shopify/presentation/home/widgets/home_search_field.dart';
import 'package:shopify/presentation/shell/main_shell_controller.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

/// مراقب تنقّل يعدّ عمليات الدفع للتحقّق من فتح شاشة المنتجات فوق الشاشة
/// الحالية (Requirements 6.9, 12.5) بلا بناء شاشة تحتاج شبكة في التحقق.
class _RecordingObserver extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}

List<CategoryModel> _categories(int count) => <CategoryModel>[
  for (int i = 1; i <= count; i++)
    CategoryModel(slug: 'slug-$i', name: 'قسم $i', url: 'u/$i'),
];

void main() {
  late _MockCatalogRepository repository;
  late SearchCubit search;

  setUp(() {
    repository = _MockCatalogRepository();
    search = SearchCubit(catalogRepository: repository);
    // القسم الأول فقط له صورة تمثيلية، فيبقى الباقي بلاطات طباعية
    // (Requirements 6.11, 6.12). الرابط فارغ حتى لا يُطلب أي شيء من الشبكة.
    when(
      () => repository.getCategoryThumbnails(),
    ).thenAnswer((_) async => const <String, String>{'slug-1': 'x.png'});
  });

  tearDown(() => search.close());

  Widget host({
    VoidCallback? onSearchRequested,
    double width = 390,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      navigatorObservers: observers,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: width,
          height: 900,
          child: BlocProvider<CategoriesCubit>(
            create: (BuildContext _) => CategoriesCubit(repository),
            child: BlocProvider<SearchCubit>.value(
              value: search,
              child: HomeScreen(onSearchRequested: onSearchRequested),
            ),
          ),
        ),
      ),
    );
  }

  /// يُقدّم إطارات محدودة بدل `pumpAndSettle` لأن هياكل الشيمر تتحرّك بلا نهاية.
  Future<void> pumpFrames(WidgetTester tester) async {
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  group('HomeScreen', () {
    testWidgets('يعرض الشيمر أثناء التحميل ثم البلاطات بعد النجاح', (
      WidgetTester tester,
    ) async {
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => _categories(4));

      await tester.pumpWidget(host());
      expect(find.byType(CategoriesShimmerGrid), findsOneWidget);

      await pumpFrames(tester);
      expect(find.byType(CategoriesShimmerGrid), findsNothing);
      expect(find.byType(CategoryTile), findsNWidgets(4));
      expect(find.text('قسم 3'), findsOneWidget);
    });

    testWidgets('كل بلاطة ثالثة بارتفاع مضاعف', (WidgetTester tester) async {
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => _categories(3));

      await tester.pumpWidget(host());
      await pumpFrames(tester);

      final List<CategoryTile> tiles = tester
          .widgetList<CategoryTile>(find.byType(CategoryTile))
          .toList();
      expect(tiles.length, 3);
      final Map<int, double> heightByOrder = <int, double>{
        for (final CategoryTile tile in tiles) tile.orderNumber: tile.height,
      };
      expect(heightByOrder[1], ShimmerMetrics.categoryTileExtent);
      expect(heightByOrder[2], ShimmerMetrics.categoryTileExtent);
      expect(heightByOrder[3], ShimmerMetrics.categoryFeaturedTileExtent);
    });

    testWidgets('البلاطة بلا صورة تعرض رقمها الترتيبي', (
      WidgetTester tester,
    ) async {
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => _categories(2));

      await tester.pumpWidget(host());
      await pumpFrames(tester);

      // القسم الثاني بلا صورة ⇒ بلاطة طباعية برقمه، والأول مصوّر فلا رقم له.
      expect(find.text('02'), findsOneWidget);
      expect(find.text('01'), findsNothing);
    });

    testWidgets('الأقسام المحمّلة تُمرَّر إلى SearchCubit للتصفية المحلية', (
      WidgetTester tester,
    ) async {
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => _categories(2));
      when(() => repository.searchProducts(any())).thenAnswer(
        (_) async => const ProductsResponseModel(
          products: <ProductModel>[],
          total: 0,
          skip: 0,
          limit: 0,
        ),
      );

      await tester.pumpWidget(host());
      await pumpFrames(tester);

      // البحث المحلي يجد القسم من القائمة المُمرَّرة بلا أي طلب أقسام إضافي.
      await search.search('قسم 2');
      expect(search.state, isA<SearchLoaded>());
      expect((search.state as SearchLoaded).categories.length, 1);
    });

    testWidgets('اختيار قسم يدفع مسارًا جديدًا فوق الشاشة الحالية', (
      WidgetTester tester,
    ) async {
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => _categories(1));
      final _RecordingObserver observer = _RecordingObserver();

      await tester.pumpWidget(host(observers: <NavigatorObserver>[observer]));
      await pumpFrames(tester);
      final int pushesBefore = observer.pushes;

      await tester.tap(find.byType(CategoryTile));
      await pumpFrames(tester);

      expect(observer.pushes, pushesBefore + 1);
    });

    testWidgets('حالة الفراغ برسالة عربية', (WidgetTester tester) async {
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => const <CategoryModel>[]);

      await tester.pumpWidget(host());
      await pumpFrames(tester);

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text(HomeScreen.emptyMessage), findsOneWidget);
    });

    testWidgets('حالة الخطأ برسالة الحالة وزر إعادة المحاولة', (
      WidgetTester tester,
    ) async {
      when(
        () => repository.getCategories(),
      ).thenThrow(const Failure('تعذّر الاتصال بالخدمة'));

      await tester.pumpWidget(host());
      await pumpFrames(tester);

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('تعذّر الاتصال بالخدمة'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      await pumpFrames(tester);
      verify(() => repository.getCategories()).called(2);
    });

    testWidgets('الضغط على حقل البحث يبلّغ الهيكل', (
      WidgetTester tester,
    ) async {
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => _categories(1));
      int taps = 0;

      await tester.pumpWidget(host(onSearchRequested: () => taps++));
      await pumpFrames(tester);

      await tester.tap(find.byType(HomeSearchField));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('بلا تجاوز في العرض 320 والعرض 900', (
      WidgetTester tester,
    ) async {
      when(
        () => repository.getCategories(),
      ).thenAnswer((_) async => _categories(5));

      for (final double width in <double>[320, 900]) {
        await tester.pumpWidget(host(width: width));
        await pumpFrames(tester);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('MainShellController', () {
    test('selectTab يتجاهل الفهارس خارج النطاق', () {
      final MainShellController controller = MainShellController();
      addTearDown(controller.dispose);

      controller.selectTab(MainShellController.profileTab);
      expect(controller.index.value, MainShellController.profileTab);

      controller.selectTab(-1);
      controller.selectTab(MainShellController.tabCount);
      expect(controller.index.value, MainShellController.profileTab);
    });

    test('openSearchTab يختار تاب البحث', () {
      final MainShellController controller = MainShellController();
      addTearDown(controller.dispose);

      controller.openSearchTab(requestFocus: false);
      expect(controller.index.value, MainShellController.searchTab);
    });
  });
}
