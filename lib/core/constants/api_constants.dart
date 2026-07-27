class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';

  static const Duration timeout = Duration(seconds: 15);

  static const String categoriesPath = '/products/categories';
  static const String productsPath = '/products';
  static const String productsByCategoryPath = '/products/category';
  static const String searchPath = '/products/search';

  static const String productSelectFields =
      'id,title,description,category,price,rating,thumbnail,images,brand,stock';

  static const String categoryThumbnailSelectFields = 'id,category,thumbnail';

  static const String googleServerClientId =
      '802072150133-ld335n5p0lk4l61beuolmc8p3a32g1ug.apps.googleusercontent.com';
}
