import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failure.dart';

typedef GoogleSignInResult = ({User user, String? displayName, String? email});

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signUp({required String email, required String password}) async {
    return _guard(() async {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return _requireUser(credential.user);
    });
  }

  Future<User> signIn({required String email, required String password}) async {
    return _guard(() async {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    });
  }

  Future<GoogleSignInResult?> signInWithGoogle() async {
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      final Failure? failure = ErrorMapper.fromGoogleSignIn(e);
      if (failure == null) return null;
      throw failure;
    } catch (e) {
      throw ErrorMapper.fromUnknown(e);
    }

    final String? idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const Failure(
        'فشل الدخول بحساب Google.',
        code: 'missing-google-id-token',
      );
    }

    return _guard(() async {
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );
      final User user = _requireUser(result.user);
      return (
        user: user,
        displayName: account.displayName ?? user.displayName,
        email: account.email.isNotEmpty ? account.email : user.email,
      );
    });
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      developer.log(
        'تعذّر تسجيل الخروج من جلسة Google: ${ErrorMapper.fromUnknown(e)}',
        name: _logName,
      );
    }
    await _guard(_auth.signOut);
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw ErrorMapper.fromFirebaseAuth(e);
    } catch (e) {
      throw ErrorMapper.fromUnknown(e);
    }
  }

  User _requireUser(User? user) {
    if (user == null) {
      throw const Failure(
        ErrorMapper.genericMessage,
        code: 'null-user-credential',
      );
    }
    return user;
  }

  static const String _logName = 'AuthService';
}
