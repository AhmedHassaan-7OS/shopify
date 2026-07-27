import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/error_mapper.dart';
import '../models/favorite_item_model.dart';
import 'user_repository.dart';

class FavoritesRepository {
  FavoritesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String favoritesCollection = 'favorites';

  static const String addedAtField = 'addedAt';

  CollectionReference<Map<String, dynamic>> _favorites(String uid) => _firestore
      .collection(UserRepository.usersCollection)
      .doc(uid)
      .collection(favoritesCollection);

  DocumentReference<Map<String, dynamic>> _favoriteDoc(
    String uid,
    int productId,
  ) => _favorites(uid).doc(productId.toString());

  Future<Set<int>> getFavoriteIds(String uid) async {
    try {
      final snapshot = await _favorites(uid).get();
      final ids = <int>{};
      for (final doc in snapshot.docs) {
        ids.add(FavoriteItem.fromDoc(doc.id, doc.data()).id);
      }
      return ids;
    } on FirebaseException catch (e) {
      throw ErrorMapper.fromFirestore(e);
    } catch (e) {
      throw ErrorMapper.fromUnknown(e);
    }
  }

  Future<List<FavoriteItem>> getFavorites(String uid) async {
    try {
      final snapshot = await _favorites(
        uid,
      ).orderBy(addedAtField, descending: true).get();
      final items = snapshot.docs
          .map((doc) => FavoriteItem.fromDoc(doc.id, doc.data()))
          .toList();
      _sortNewestFirst(items);
      return items;
    } on FirebaseException catch (e) {
      throw ErrorMapper.fromFirestore(e);
    } catch (e) {
      throw ErrorMapper.fromUnknown(e);
    }
  }

  Future<void> add(String uid, FavoriteItem item) async {
    try {
      await _favoriteDoc(uid, item.id).set(item.toMap());
    } on FirebaseException catch (e) {
      throw ErrorMapper.fromFirestore(e);
    } catch (e) {
      throw ErrorMapper.fromUnknown(e);
    }
  }

  Future<void> remove(String uid, int productId) async {
    try {
      await _favoriteDoc(uid, productId).delete();
    } on FirebaseException catch (e) {
      throw ErrorMapper.fromFirestore(e);
    } catch (e) {
      throw ErrorMapper.fromUnknown(e);
    }
  }

  static void _sortNewestFirst(List<FavoriteItem> items) {
    items.sort((a, b) {
      final aAt = a.addedAt;
      final bAt = b.addedAt;
      if (aAt == null && bAt == null) return 0;
      if (aAt == null) return -1;
      if (bAt == null) return 1;
      return bAt.compareTo(aAt);
    });
  }
}
