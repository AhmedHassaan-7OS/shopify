import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const <Object?>[];

  @override
  bool get stringify => true;
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading({this.googleFlow = false});

  final bool googleFlow;

  @override
  List<Object?> get props => <Object?>[googleFlow];
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.uid);

  final String uid;

  @override
  List<Object?> get props => <Object?>[uid];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
