import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'failure.dart';

class ErrorMapper {
  const ErrorMapper._();

  static const String genericMessage = 'حدث خطأ غير متوقع، حاول مرة أخرى.';

  static const String timeoutMessage =
      'انتهت مهلة الاتصال، تحقّق من الإنترنت وحاول مرة أخرى.';

  static const String noConnectionMessage = 'لا يوجد اتصال بالإنترنت.';

  static Failure fromFirebaseAuth(FirebaseAuthException e) {
    final code = e.code;
    final message = switch (code) {
      'email-already-in-use' => 'هذا البريد مُستخدم بالفعل.',
      'invalid-email' => 'صيغة البريد غير صحيحة.',
      'weak-password' => 'كلمة المرور ضعيفة، استخدم 6 محارف على الأقل.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'البريد أو كلمة المرور غير صحيحة.',
      'user-disabled' => 'تم تعطيل هذا الحساب.',
      'too-many-requests' => 'محاولات كثيرة، حاول بعد قليل.',
      'network-request-failed' => 'تحقّق من اتصالك بالإنترنت.',
      _ => genericMessage,
    };
    return Failure(message, code: code.isEmpty ? null : code);
  }

  static Failure fromDio(DioException e) {
    final code = e.type.name;
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => Failure(timeoutMessage, code: code),
      DioExceptionType.connectionError => Failure(
        noConnectionMessage,
        code: code,
      ),
      DioExceptionType.badResponse => _fromBadResponse(e),
      _ => Failure(genericMessage, code: code),
    };
  }

  static Failure fromFirestore(FirebaseException e) {
    final code = e.code;
    final message = switch (code) {
      'permission-denied' => 'لا تملك صلاحية الوصول لهذه البيانات.',
      'unauthenticated' => 'يجب تسجيل الدخول أولًا.',
      'unavailable' => 'الخدمة غير متاحة حاليًا، حاول لاحقًا.',
      'deadline-exceeded' => timeoutMessage,
      'not-found' => 'لم يتم العثور على البيانات المطلوبة.',
      _ => genericMessage,
    };
    return Failure(message, code: code.isEmpty ? null : code);
  }

  static Failure? fromGoogleSignIn(Object e) {
    if (e is! GoogleSignInException) {
      return fromUnknown(e);
    }
    if (e.code == GoogleSignInExceptionCode.canceled) {
      return null;
    }
    return Failure('فشل الدخول بحساب Google.', code: e.code.name);
  }

  static Failure fromUnknown(Object e) {
    if (e is Failure) return e;
    if (e is FirebaseAuthException) return fromFirebaseAuth(e);
    if (e is FirebaseException) return fromFirestore(e);
    if (e is DioException) return fromDio(e);
    if (e is GoogleSignInException) {
      return Failure('فشل الدخول بحساب Google.', code: e.code.name);
    }
    return Failure(genericMessage, code: e.runtimeType.toString());
  }

  static Failure _fromBadResponse(DioException e) {
    final status = e.response?.statusCode;
    final code = status == null
        ? DioExceptionType.badResponse.name
        : status.toString();
    if (status == null) {
      return Failure(genericMessage, code: code);
    }
    if (status >= 500) {
      return Failure('الخادم غير متاح حاليًا، حاول لاحقًا.', code: code);
    }
    if (status >= 400) {
      return Failure('لم نتمكن من جلب البيانات (كود $status).', code: code);
    }
    return Failure(genericMessage, code: code);
  }
}
