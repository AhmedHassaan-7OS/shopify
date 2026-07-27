import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopify/core/theme/app_theme.dart';
import 'package:shopify/data/models/app_user_model.dart';
import 'package:shopify/data/repositories/user_repository.dart';
import 'package:shopify/data/services/auth_service.dart';
import 'package:shopify/presentation/profile/profile_screen.dart';
import 'package:shopify/presentation/profile/widgets/profile_info_tile.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockUser extends Mock implements User {}

const String _uid = 'uid-1';

Widget _host({
  required AuthService authService,
  required UserRepository userRepository,
  double width = 390,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: width,
        child: ProfileScreen(
          authService: authService,
          userRepository: userRepository,
        ),
      ),
    ),
  );
}

void main() {
  late _MockAuthService auth;
  late FakeFirebaseFirestore firestore;

  setUp(() {
    auth = _MockAuthService();
    final _MockUser user = _MockUser();
    when(() => user.uid).thenReturn(_uid);
    when(() => auth.currentUser).thenReturn(user);
    firestore = FakeFirebaseFirestore();
  });

  UserRepository repository() => UserRepository(firestore: firestore);

  testWidgets('يعرض الأفاتار بأول حرف من الاسم مع الاسم والهاتف والبريد', (
    WidgetTester tester,
  ) async {
    await firestore
        .collection('users')
        .doc(_uid)
        .set(
          const AppUser(
            uid: _uid,
            name: 'أحمد سالم',
            phone: '0100000000',
            email: 'ahmed@example.com',
          ).toMap(),
        );

    await tester.pumpWidget(
      _host(authService: auth, userRepository: repository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('أ'), findsOneWidget);
    expect(find.text('أحمد سالم'), findsWidgets);
    expect(find.text('0100000000'), findsWidgets);
    expect(find.text('ahmed@example.com'), findsWidgets);
    expect(find.byType(ProfileInfoTile), findsNWidgets(3));
    expect(find.text(ProfileScreen.logoutLabel), findsOneWidget);
    expect(find.byIcon(Symbols.logout), findsOneWidget);
  });

  testWidgets('الاسم الفارغ يعرض أيقونة بدل الحرف بدون انهيار', (
    WidgetTester tester,
  ) async {
    await firestore
        .collection('users')
        .doc(_uid)
        .set(
          const AppUser(
            uid: _uid,
            name: '   ',
            phone: '',
            email: 'empty@example.com',
          ).toMap(),
        );

    await tester.pumpWidget(
      _host(authService: auth, userRepository: repository()),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Symbols.person), findsWidgets);
    expect(find.text('empty@example.com'), findsWidgets);
  });

  testWidgets('غياب الوثيقة يعرض حالة فراغ عربية مع زر إعادة المحاولة', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(authService: auth, userRepository: repository()),
    );
    await tester.pumpAndSettle();

    expect(find.text(ProfileScreen.emptyMessage), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });

  testWidgets('غياب الجلسة يعرض رسالة خطأ عربية مع إعادة المحاولة', (
    WidgetTester tester,
  ) async {
    when(() => auth.currentUser).thenReturn(null);

    await tester.pumpWidget(
      _host(authService: auth, userRepository: repository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.byIcon(Symbols.error), findsOneWidget);
  });
}
