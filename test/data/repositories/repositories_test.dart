import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopify/data/models/app_user_model.dart';
import 'package:shopify/data/models/favorite_item_model.dart';
import 'package:shopify/data/repositories/favorites_repository.dart';
import 'package:shopify/data/repositories/user_repository.dart';

void main() {
  group('UserRepository', () {
    test('saveUser يكتب name/phone/email فقط بمعرّف وثيقة = uid', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = UserRepository(firestore: firestore);

      await repo.saveUser(
        const AppUser(
          uid: 'uid-1',
          name: 'أحمد',
          phone: '0100000000',
          email: 'a@b.com',
        ),
      );

      final doc = await firestore.collection('users').doc('uid-1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!.keys.toSet(), {'name', 'phone', 'email'});
      expect(doc.data()!['name'], 'أحمد');
    });

    test('saveUser يدمج ولا يمسح الحقول الموجودة', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = UserRepository(firestore: firestore);
      await firestore.collection('users').doc('uid-1').set({
        'name': 'قديم',
        'phone': '0100000000',
        'email': 'old@b.com',
      });

      await repo.saveUser(
        const AppUser(
          uid: 'uid-1',
          name: 'جديد',
          phone: '',
          email: 'new@b.com',
        ),
      );

      final doc = await firestore.collection('users').doc('uid-1').get();
      expect(doc.data()!['name'], 'جديد');
      expect(doc.data()!['email'], 'new@b.com');
    });

    test('getUser يعيد null عند غياب الوثيقة', () async {
      final repo = UserRepository(firestore: FakeFirebaseFirestore());
      expect(await repo.getUser('missing'), isNull);
    });

    test('getUser يعيد AppUser بمعرّف الوثيقة كـ uid', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('uid-2').set({
        'name': 'سارة',
        'phone': '0111',
        'email': 's@b.com',
      });

      final user = await UserRepository(firestore: firestore).getUser('uid-2');

      expect(
        user,
        const AppUser(
          uid: 'uid-2',
          name: 'سارة',
          phone: '0111',
          email: 's@b.com',
        ),
      );
    });
  });

  group('FavoritesRepository', () {
    FavoriteItem item(int id, {DateTime? addedAt}) => FavoriteItem(
      id: id,
      title: 'منتج $id',
      price: id * 1.5,
      rating: 4.5,
      thumbnail: 'https://x/$id.png',
      addedAt: addedAt,
    );

    test('add يكتب الوثيقة بمعرّف = productId وبالحقول الستة', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FavoritesRepository(firestore: firestore);

      await repo.add('uid-1', item(7, addedAt: DateTime.utc(2024, 1, 1)));

      final doc = await firestore
          .collection('users')
          .doc('uid-1')
          .collection('favorites')
          .doc('7')
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!.keys.toSet(), {
        'id',
        'title',
        'price',
        'rating',
        'thumbnail',
        'addedAt',
      });
      expect(doc.data()!['id'], 7);
      expect(doc.data()!['addedAt'], isA<Timestamp>());
    });

    test('remove يحذف الوثيقة و getFavoriteIds يعكس المتبقي', () async {
      final repo = FavoritesRepository(firestore: FakeFirebaseFirestore());
      await repo.add('uid-1', item(1, addedAt: DateTime.utc(2024, 1, 1)));
      await repo.add('uid-1', item(2, addedAt: DateTime.utc(2024, 1, 2)));

      await repo.remove('uid-1', 1);

      expect(await repo.getFavoriteIds('uid-1'), {2});
    });

    test('getFavorites يرتّب addedAt تنازليًا', () async {
      final repo = FavoritesRepository(firestore: FakeFirebaseFirestore());
      await repo.add('uid-1', item(1, addedAt: DateTime.utc(2024, 1, 1)));
      await repo.add('uid-1', item(2, addedAt: DateTime.utc(2024, 3, 1)));
      await repo.add('uid-1', item(3, addedAt: DateTime.utc(2024, 2, 1)));

      final items = await repo.getFavorites('uid-1');

      expect(items.map((e) => e.id).toList(), [2, 3, 1]);
    });

    test('getFavorites يحتفظ بالعنصر بلا addedAt ويضعه أولًا', () async {
      final firestore = FakeFirebaseFirestore();
      final repo = FavoritesRepository(firestore: firestore);
      await repo.add('uid-1', item(1, addedAt: DateTime.utc(2024, 1, 1)));
      await firestore
          .collection('users')
          .doc('uid-1')
          .collection('favorites')
          .doc('9')
          .set({
            'id': 9,
            'title': 'قيد الحفظ',
            'price': 10.0,
            'rating': 4.0,
            'thumbnail': '',
            'addedAt': null,
          });

      final items = await repo.getFavorites('uid-1');

      expect(items.map((e) => e.id).toList(), [9, 1]);
    });

    test('getFavoriteIds يعيد مجموعة فارغة عند غياب المفضّلة', () async {
      final repo = FavoritesRepository(firestore: FakeFirebaseFirestore());
      expect(await repo.getFavoriteIds('uid-x'), isEmpty);
    });
  });
}
