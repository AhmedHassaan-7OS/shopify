import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopify/core/constants/api_constants.dart';
import 'package:shopify/core/errors/error_mapper.dart';
import 'package:shopify/core/errors/failure.dart';
import 'package:shopify/data/models/products_response_model.dart';
import 'package:shopify/data/repositories/catalog_repository.dart';
import 'package:shopify/data/services/api_provider.dart';

/// بديل عن الشبكة فقط: يسجّل المسار والبارامترات ويعيد جسمًا مُعدًّا مسبقًا،
/// أو يرمي `DioException` لاختبار التحويل إلى `Failure`.
class _RecordingApiProvider extends ApiProvider {
  _RecordingApiProvider({this.body, this.error}) : super(enableLogging: false);

  final dynamic body;
  final DioException? error;

  String? lastPath;
  Map<String, dynamic>? lastQuery;

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    lastPath = path;
    lastQuery = queryParameters;
    if (error != null) return Future<dynamic>.error(error!);
    return Future<dynamic>.value(body);
  }
}

DioException _dioError(DioExceptionType type) => DioException(
  requestOptions: RequestOptions(path: '/products'),
  type: type,
);

void main() {
  group('ApiProvider configuration', () {
    test('يضبط المهلات الثلاث على 15 ثانية و baseUrl على DummyJSON', () {
      final ApiProvider provider = ApiProvider(enableLogging: false);
      final BaseOptions options = provider.dio.options;

      expect(options.baseUrl, ApiConstants.baseUrl);
      expect(options.connectTimeout, const Duration(seconds: 15));
      expect(options.sendTimeout, const Duration(seconds: 15));
      expect(options.receiveTimeout, const Duration(seconds: 15));
    });
  });

  group('CatalogRepository.getCategories', () {
    test('يحلّل مصفوفة الأقسام المباشرة', () async {
      final api = _RecordingApiProvider(
        body: <dynamic>[
          <String, dynamic>{
            'slug': 'smartphones',
            'name': 'Smartphones',
            'url': 'https://dummyjson.com/products/category/smartphones',
          },
        ],
      );

      final categories = await CatalogRepository(
        apiProvider: api,
      ).getCategories();

      expect(api.lastPath, '/products/categories');
      expect(categories.single.slug, 'smartphones');
      expect(categories.single.name, 'Smartphones');
    });

    test('يحوّل انتهاء المهلة إلى Failure برسالة عربية', () async {
      final api = _RecordingApiProvider(
        error: _dioError(DioExceptionType.receiveTimeout),
      );

      await expectLater(
        CatalogRepository(apiProvider: api).getCategories(),
        throwsA(
          isA<Failure>().having(
            (Failure f) => f.message,
            'message',
            ErrorMapper.timeoutMessage,
          ),
        ),
      );
    });
  });

  group('CatalogRepository.getCategoryThumbnails', () {
    test('يأخذ أول thumbnail لكل قسم ويتجاهل الناقص', () async {
      final api = _RecordingApiProvider(
        body: <String, dynamic>{
          'products': <dynamic>[
            <String, dynamic>{'id': 1, 'category': 'beauty', 'thumbnail': 'a'},
            <String, dynamic>{'id': 2, 'category': 'beauty', 'thumbnail': 'b'},
            <String, dynamic>{'id': 3, 'category': 'groceries'},
            <String, dynamic>{'id': 4, 'category': '', 'thumbnail': 'c'},
            <String, dynamic>{
              'id': 5,
              'category': 'furniture',
              'thumbnail': 'd',
            },
          ],
        },
      );

      final thumbnails = await CatalogRepository(
        apiProvider: api,
      ).getCategoryThumbnails();

      expect(api.lastPath, '/products');
      expect(api.lastQuery, <String, dynamic>{
        'limit': 0,
        'select': 'id,category,thumbnail',
      });
      expect(thumbnails, <String, String>{'beauty': 'a', 'furniture': 'd'});
    });
  });

  group('CatalogRepository products requests', () {
    test('getProductsByCategory يبني المسار مع select المحدد', () async {
      final api = _RecordingApiProvider(
        body: <String, dynamic>{
          'products': <dynamic>[
            <String, dynamic>{'id': 7, 'title': 'iPhone', 'price': 999},
          ],
          'total': 1,
          'skip': 0,
          'limit': 1,
        },
      );

      final ProductsResponseModel response = await CatalogRepository(
        apiProvider: api,
      ).getProductsByCategory('smartphones');

      expect(api.lastPath, '/products/category/smartphones');
      expect(api.lastQuery!['select'], ApiConstants.productSelectFields);
      expect(response.products.single.id, 7);
      expect(response.total, 1);
    });

    test('searchProducts يمرّر q و select', () async {
      final api = _RecordingApiProvider(
        body: <String, dynamic>{
          'products': <dynamic>[],
          'total': 0,
          'skip': 0,
          'limit': 0,
        },
      );

      final ProductsResponseModel response = await CatalogRepository(
        apiProvider: api,
      ).searchProducts('lap top');

      expect(api.lastPath, '/products/search');
      expect(api.lastQuery, <String, dynamic>{
        'q': 'lap top',
        'select': ApiConstants.productSelectFields,
      });
      expect(response.products, isEmpty);
    });

    test(
      'استجابة غير متوقّعة (غير كائن) تعيد استجابة فارغة بلا استثناء',
      () async {
        final api = _RecordingApiProvider(body: 'unexpected');

        final ProductsResponseModel response = await CatalogRepository(
          apiProvider: api,
        ).searchProducts('ab');

        expect(response.products, isEmpty);
        expect(response.total, 0);
      },
    );
  });
}
