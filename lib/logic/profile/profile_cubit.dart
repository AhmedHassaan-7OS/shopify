import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/error_mapper.dart';
import '../../data/models/app_user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthService authService,
    required UserRepository userRepository,
  }) : _authService = authService,
       _userRepository = userRepository,
       super(const ProfileInitial());

  final AuthService _authService;
  final UserRepository _userRepository;

  static final String _noSessionMessage = ErrorMapper.fromFirestore(
    FirebaseException(plugin: 'cloud_firestore', code: 'unauthenticated'),
  ).message;

  Future<void> load() async {
    if (isClosed) return;
    emit(const ProfileLoading());

    final String? uid = _authService.currentUser?.uid;
    if (uid == null) {
      if (isClosed) return;
      emit(ProfileError(_noSessionMessage));
      return;
    }

    try {
      final AppUser? user = await _userRepository.getUser(uid);
      if (isClosed) return;
      if (user == null) {
        emit(const ProfileEmpty());
        return;
      }
      emit(ProfileLoaded(user));
    } catch (e) {
      if (isClosed) return;
      emit(ProfileError(ErrorMapper.fromUnknown(e).message));
    }
  }

  Future<void> retry() => load();
}
