import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/error_mapper.dart';
import '../models/app_user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String usersCollection = 'users';

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(usersCollection).doc(uid);

  Future<void> saveUser(AppUser user) async {
    try {
      await _userDoc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ErrorMapper.fromFirestore(e);
    } catch (e) {
      throw ErrorMapper.fromUnknown(e);
    }
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      final snapshot = await _userDoc(uid).get();
      if (!snapshot.exists) return null;
      return AppUser.fromDoc(snapshot.id, snapshot.data());
    } on FirebaseException catch (e) {
      throw ErrorMapper.fromFirestore(e);
    } catch (e) {
      throw ErrorMapper.fromUnknown(e);
    }
  }
}
