import 'package:equatable/equatable.dart';

import '../../data/models/app_user_model.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);

  final AppUser user;

  @override
  List<Object?> get props => <Object?>[user];
}

final class ProfileEmpty extends ProfileState {
  const ProfileEmpty();
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
