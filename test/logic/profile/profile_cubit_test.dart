import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopify/core/errors/failure.dart';
import 'package:shopify/data/models/app_user_model.dart';
import 'package:shopify/data/repositories/user_repository.dart';
import 'package:shopify/data/services/auth_service.dart';
import 'package:shopify/logic/profile/profile_cubit.dart';
import 'package:shopify/logic/profile/profile_state.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockUser extends Mock implements User {}

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  const uid = 'uid-1';
  const stored = AppUser(
    uid: uid,
    name: 'أحمد',
    phone: '0100000000',
    email: 'a@b.com',
  );

  late _MockAuthService auth;

  /// مستودع حقيقي فوق Firestore مزيّف — بلا mocks لطبقة البيانات.
  UserRepository repositoryWith({Map<String, dynamic>? doc}) {
    final firestore = FakeFirebaseFirestore();
    if (doc != null) {
      firestore.collection('users').doc(uid).set(doc);
    }
    return UserRepository(firestore: firestore);
  }

  void signedIn() {
    final user = _MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => auth.currentUser).thenReturn(user);
  }

  setUp(() {
    auth = _MockAuthService();
  });

  group('ProfileCubit.load', () {
    test('الحالة الابتدائية هي ProfileInitial', () {
      when(() => auth.currentUser).thenReturn(null);
      expect(
        ProfileCubit(authService: auth, userRepository: repositoryWith()).state,
        const ProfileInitial(),
      );
    });

    blocTest<ProfileCubit, ProfileState>(
      'وثيقة موجودة → Loading ثم Loaded ببيانات المستخدم',
      setUp: signedIn,
      build: () => ProfileCubit(
        authService: auth,
        userRepository: repositoryWith(doc: stored.toMap()),
      ),
      act: (cubit) => cubit.load(),
      expect: () => const [ProfileLoading(), ProfileLoaded(stored)],
    );

    blocTest<ProfileCubit, ProfileState>(
      'وثيقة غير موجودة → Loading ثم ProfileEmpty وليست خطأ',
      setUp: signedIn,
      build: () =>
          ProfileCubit(authService: auth, userRepository: repositoryWith()),
      act: (cubit) => cubit.load(),
      expect: () => const [ProfileLoading(), ProfileEmpty()],
    );

    blocTest<ProfileCubit, ProfileState>(
      'لا يوجد مستخدم حالي → Loading ثم خطأ برسالة عربية',
      setUp: () => when(() => auth.currentUser).thenReturn(null),
      build: () => ProfileCubit(
        authService: auth,
        userRepository: repositoryWith(doc: stored.toMap()),
      ),
      act: (cubit) => cubit.load(),
      expect: () => const [
        ProfileLoading(),
        ProfileError('يجب تسجيل الدخول أولًا.'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'فشل القراءة → Loading ثم خطأ برسالة الـ Failure',
      setUp: signedIn,
      build: () {
        final repo = _MockUserRepository();
        when(
          () => repo.getUser(uid),
        ).thenThrow(const Failure('لا تملك صلاحية الوصول لهذه البيانات.'));
        return ProfileCubit(authService: auth, userRepository: repo);
      },
      act: (cubit) => cubit.load(),
      expect: () => const [
        ProfileLoading(),
        ProfileError('لا تملك صلاحية الوصول لهذه البيانات.'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'تحميل جديد فوق بيانات معروضة يصدر Loading أولًا (Requirement 5.2)',
      setUp: signedIn,
      build: () => ProfileCubit(
        authService: auth,
        userRepository: repositoryWith(doc: stored.toMap()),
      ),
      seed: () => const ProfileLoaded(stored),
      act: (cubit) => cubit.load(),
      expect: () => const [ProfileLoading(), ProfileLoaded(stored)],
    );

    blocTest<ProfileCubit, ProfileState>(
      'retry يكرّر نفس عملية القراءة (Requirement 5.6)',
      setUp: signedIn,
      build: () => ProfileCubit(
        authService: auth,
        userRepository: repositoryWith(doc: stored.toMap()),
      ),
      seed: () => const ProfileError('خطأ سابق'),
      act: (cubit) => cubit.retry(),
      expect: () => const [ProfileLoading(), ProfileLoaded(stored)],
    );
  });
}
