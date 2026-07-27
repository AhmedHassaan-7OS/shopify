import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopify/data/models/app_user_model.dart';
import 'package:shopify/data/models/category_model.dart';
import 'package:shopify/data/models/favorite_item_model.dart';
import 'package:shopify/data/models/product_model.dart';
import 'package:shopify/data/models/products_response_model.dart';

Map<String, dynamic> _roundTrip(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

void main() {
  group('CategoryModel', () {
    test('round trip يحفظ كل الحقول', () {
      const category = CategoryModel(
        slug: 'smartphones',
        name: 'هواتف ذكية',
        url: 'https://dummyjson.com/products/category/smartphones',
      );
      expect(
        CategoryModel.fromJson(_roundTrip(category.toJson())),
        equals(category),
      );
    });

    test('listFromJson يحلّل المصفوفة مباشرة', () {
      final list = CategoryModel.listFromJson(<dynamic>[
        <String, dynamic>{'slug': 'beauty', 'name': 'Beauty', 'url': 'u'},
        <String, dynamic>{'slug': 'fragrances'},
      ]);
      expect(list, hasLength(2));
      expect(list.first.name, 'Beauty');
      expect(list.last.name, isEmpty);
    });

    test('listFromJson يعيد قائمة فارغة لغير المصفوفة', () {
      expect(CategoryModel.listFromJson(<String, dynamic>{}), isEmpty);
    });

    test('fromJson متسامح مع الحقول الناقصة', () {
      final category = CategoryModel.fromJson(<String, dynamic>{});
      expect(category, const CategoryModel(slug: '', name: '', url: ''));
    });
  });

  group('ProductModel', () {
    const product = ProductModel(
      id: 7,
      title: 'iPhone 14 Pro',
      description: 'وصف المنتج',
      category: 'smartphones',
      price: 1099.5,
      rating: 4.5,
      thumbnail: 'https://example.com/t.png',
      images: <String>['https://example.com/1.png'],
      brand: 'Apple',
      stock: 12,
    );

    test('round trip يحفظ كل الحقول بما فيها brand و stock', () {
      expect(ProductModel.fromJson(_roundTrip(product.toJson())), product);
    });

    test('الأرقام الصحيحة تُحوَّل إلى double', () {
      final parsed = ProductModel.fromJson(<String, dynamic>{
        'id': 1,
        'price': 100,
        'rating': 5,
      });
      expect(parsed.price, 100.0);
      expect(parsed.rating, 5.0);
      expect(ProductModel.fromJson(parsed.toJson()), parsed);
    });

    test('JSON فارغ ينتج كائنًا صالحًا بقيم افتراضية', () {
      final parsed = ProductModel.fromJson(<String, dynamic>{});
      expect(parsed.id, 0);
      expect(parsed.price, 0);
      expect(parsed.rating, 0);
      expect(parsed.stock, 0);
      expect(parsed.brand, isEmpty);
      expect(parsed.images, isEmpty);
    });

    test('images من نوع غير قائمة تصبح قائمة فارغة', () {
      expect(
        ProductModel.fromJson(<String, dynamic>{'images': 'x'}).images,
        isEmpty,
      );
    });

    test('galleryImages ترجع thumbnail عند فراغ images', () {
      final parsed = ProductModel.fromJson(<String, dynamic>{
        'thumbnail': 't',
        'images': <dynamic>[],
      });
      expect(parsed.galleryImages, <String>['t']);
    });
  });

  group('ProductsResponseModel', () {
    test('round trip يحفظ المنتجات والأعداد', () {
      const response = ProductsResponseModel(
        products: <ProductModel>[
          ProductModel(
            id: 1,
            title: 't',
            description: 'd',
            category: 'c',
            price: 1,
            rating: 2,
            thumbnail: 'th',
            images: <String>['a', 'b'],
            brand: 'b',
            stock: 3,
          ),
        ],
        total: 30,
        skip: 0,
        limit: 30,
      );
      expect(
        ProductsResponseModel.fromJson(_roundTrip(response.toJson())),
        response,
      );
    });

    test('استجابة ناقصة تنتج قائمة فارغة وأصفارًا', () {
      final parsed = ProductsResponseModel.fromJson(<String, dynamic>{
        'products': null,
      });
      expect(parsed, ProductsResponseModel.empty);
    });
  });

  group('AppUser', () {
    const user = AppUser(
      uid: 'uid-1',
      name: 'أحمد',
      phone: '+201234567',
      email: 'a@b.com',
    );

    test('toMap يحتوي name و phone و email فقط', () {
      expect(
        user.toMap().keys,
        containsAll(<String>['name', 'phone', 'email']),
      );
      expect(user.toMap(), hasLength(3));
      expect(user.toMap().containsKey('uid'), isFalse);
      expect(user.toMap().containsKey('password'), isFalse);
    });

    test('round trip عبر معرّف الوثيقة', () {
      expect(AppUser.fromDoc(user.uid, _roundTrip(user.toMap())), user);
    });

    test('وثيقة ناقصة أو null تنتج نصوصًا فارغة', () {
      expect(
        AppUser.fromDoc('u', null),
        const AppUser(uid: 'u', name: '', phone: '', email: ''),
      );
    });
  });

  group('FavoriteItem', () {
    test('round trip بالـ JSON يحفظ addedAt', () {
      final item = FavoriteItem(
        id: 5,
        title: 'منتج',
        price: 10.5,
        rating: 4.2,
        thumbnail: 'th',
        addedAt: DateTime.utc(2024, 5, 1, 10, 30),
      );
      expect(FavoriteItem.fromJson(_roundTrip(item.toJson())), item);
    });

    test('toMap يستخدم وقت الخادم عند غياب addedAt', () {
      final item = FavoriteItem(
        id: 5,
        title: 'منتج',
        price: 10,
        rating: 4,
        thumbnail: 'th',
      );
      expect(item.toMap()['addedAt'], isA<FieldValue>());
    });

    test('toMap يكتب Timestamp عند وجود addedAt', () {
      final item = FavoriteItem(
        id: 5,
        title: 'منتج',
        price: 10,
        rating: 4,
        thumbnail: 'th',
        addedAt: DateTime.utc(2024, 1, 1),
      );
      expect(item.toMap()['addedAt'], isA<Timestamp>());
    });

    test('fromDoc يقرأ Timestamp ويطبّعه إلى UTC', () {
      final date = DateTime.utc(2024, 3, 3, 8);
      final item = FavoriteItem.fromDoc('5', <String, dynamic>{
        'id': 5,
        'title': 'منتج',
        'price': 10,
        'rating': 4,
        'thumbnail': 'th',
        'addedAt': Timestamp.fromDate(date),
      });
      expect(item.addedAt, date);
      expect(item.addedAt!.isUtc, isTrue);
    });

    test('fromDoc يرجع لمعرّف الوثيقة عند غياب id ويقبل addedAt فارغًا', () {
      final item = FavoriteItem.fromDoc('42', <String, dynamic>{});
      expect(item.id, 42);
      expect(item.addedAt, isNull);
      expect(item.title, isEmpty);
    });

    test('fromProduct ينقل حقول العرض فقط', () {
      const product = ProductModel(
        id: 3,
        title: 't',
        description: 'd',
        category: 'c',
        price: 9.99,
        rating: 3.5,
        thumbnail: 'th',
        images: <String>[],
        brand: 'b',
        stock: 1,
      );
      final item = FavoriteItem.fromProduct(product);
      expect(item.id, 3);
      expect(item.price, 9.99);
      expect(item.rating, 3.5);
      expect(item.thumbnail, 'th');
      expect(item.addedAt, isNull);
    });
  });
}
