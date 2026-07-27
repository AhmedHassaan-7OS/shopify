import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failure.dart';
import '../../data/models/app_user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';
import 'auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthService authService,
    required UserRepository userRepository,
  }) : _authService = authService,
       _userRepository = userRepository,
       super(const AuthInitial()) {
    _authSubscription = _authService.authStateChanges().listen(
      _onAuthUserChanged,
    );
  }

  final AuthService _authService;
  final UserRepository _userRepository;

  late final StreamSubscription<User?> _authSubscription;

  bool _operationInFlight = false;

  User? _pendingUser;
  bool _hasPendingUser = false;

  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    await _run(const AuthLoading(), () async {
      final User user = await _authService.signUp(
        email: email,
        password: password,
      );
      await _userRepository.saveUser(
        AppUser(uid: user.uid, name: name, phone: phone, email: email),
      );
      return AuthAuthenticated(user.uid);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _run(const AuthLoading(), () async {
      final User user = await _authService.signIn(
        email: email,
        password: password,
      );
      return AuthAuthenticated(user.uid);
    });
  }

  Future<void> signInWithGoogle() async {
    await _run(const AuthLoading(googleFlow: true), () async {
      final GoogleSignInResult? result = await _authService.signInWithGoogle();
      if (result == null) return const AuthUnauthenticated();

      final String uid = result.user.uid;
      final AppUser? existing = await _userRepository.getUser(uid);
      await _userRepository.saveUser(
        AppUser(
          uid: uid,
          name: result.displayName ?? existing?.name ?? '',
          phone: existing?.phone ?? '',
          email: result.email ?? existing?.email ?? '',
        ),
      );
      return AuthAuthenticated(uid);
    });
  }

  Future<void> signOut() async {
    emit(const AuthUnauthenticated());
    try {
      await _authService.signOut();
    } catch (e) {
      developer.log(
        'فشل تسجيل الخروج: ${ErrorMapper.fromUnknown(e).message}',
        name: _logName,
      );
    }
  }

  Future<void> _run(
    AuthLoading loading,
    Future<AuthState> Function() action,
  ) async {
    if (isClosed) return;
    _operationInFlight = true;
    _hasPendingUser = false;
    _pendingUser = null;
    emit(loading);
    AuthState result;
    try {
      result = await action();
    } on Failure catch (failure) {
      result = AuthError(failure.message);
    } catch (e) {
      result = AuthError(ErrorMapper.fromUnknown(e).message);
    } finally {
      _operationInFlight = false;
    }
    if (isClosed) return;
    emit(result);
    _applyPendingUser(result);
  }

  void _applyPendingUser(AuthState result) {
    if (!_hasPendingUser) return;
    final User? user = _pendingUser;
    _hasPendingUser = false;
    _pendingUser = null;

    final AuthState fromStream = user == null
        ? const AuthUnauthenticated()
        : AuthAuthenticated(user.uid);
    if (fromStream != result) emit(fromStream);
  }

  void _onAuthUserChanged(User? user) {
    if (isClosed) return;
    if (_operationInFlight) {
      _pendingUser = user;
      _hasPendingUser = true;
      return;
    }
    emit(
      user == null ? const AuthUnauthenticated() : AuthAuthenticated(user.uid),
    );
  }

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    return super.close();
  }

  static const String _logName = 'AuthCubit';
}
