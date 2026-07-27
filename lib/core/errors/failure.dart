import 'package:equatable/equatable.dart';

class Failure extends Equatable implements Exception {
  const Failure(this.message, {this.code});

  final String message;

  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() =>
      code == null ? 'Failure($message)' : 'Failure($message, code: $code)';
}
