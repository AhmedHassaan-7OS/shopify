import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopify/core/errors/failure.dart';
import 'package:shopify/core/theme/app_theme.dart';
import 'package:shopify/data/models/favorite_item_model.dart';
import 'package:shopify/data/repositories/favorites_repository.dart';
import 'package:shopify/data/services/auth_service.dart';
import 'package:shopify/logic/favorites/favorites_cubit.dart';
import 'package:shopify/presentation/favorites/favorites_screen.dart';
import 'package:shopify/presentation/favorites/widgets/favorite_tile.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockUser extends Mock implements User {}

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

const String _uid = 'uid-1';

Widget _host(FavoritesCubit cubit, {double width = 390}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: width,
        child: BlocProvider<FavoritesCubit>.value(
          value: cubit,
          child: const FavoritesScreen(),
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

  FavoritesCubit cubitWith(FavoritesRepository repository) =>
      FavoritesCubit(favoritesRepository: repository, authService: auth);

  Future<void> seed({
    required int id,
    required String title,
    required double price,
    required double rating,
  }) => firestore
      .collection('users')
      .doc(_uid)
      .collection('favorites')
      .doc(id.toString())
      .set(<String, dynamic>{
        'id': id,
        'title': title,
        'price': price,
        'rating': rating,
        'thumbnail': 'https://example.com/$id.png',
        'addedAt': Timestamp.fromMillisecondsSinceEpoch(1000 + id),
      });

  testWidgets('يعرض العنوان والسعر والتقييم لكل عنصر مفضّلة', (
    WidgetTester tester,
  ) async {
    await seed(id: 7, title: 'ساعة أنيقة', price: 120.5, rating: 4.25);
    final FavoritesCubit cubit = cubitWith(
      FavoritesRepository(firestore: firestore),
    );
    addTearDown(cubit.close);

    await cubit.load();
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    expect(find.byType(FavoriteTile), findsOneWidget);
    expect(find.text('ساعة أنيقة'), findsOneWidget);
    expect(find.text(r'$120.50'), findsOneWidget);
    expect(find.text('4.3'), findsOneWidget);
  });

  testWidgets('قائمة فارغة تعرض رسالة الفراغ العربية', (
    WidgetTester tester,
  ) async {
    final FavoritesCubit cubit = cubitWith(
      FavoritesRepository(firestore: firestore),
    );
    addTearDown(cubit.close);

    await cubit.load();
    await tester.pumpWidget(_host(cubit));
    await tester.pump();

    expect(find.byType(FavoriteTile), findsNothing);
    expect(find.text(FavoritesScreen.emptyMessage), findsOneWidget);
  });

  testWidgets('فشل الحذف يعيد العنصر ويعرض الرسالة في SnackBar', (
    WidgetTester tester,
  ) async {
    final _MockFavoritesRepository repository = _MockFavoritesRepository();
    final FavoriteItem item = FavoriteItem(
      id: 3,
      title: 'حقيبة جلد',
      price: 80,
      rating: 4,
      thumbnail: 'https://example.com/3.png',
      addedAt: DateTime.utc(2024),
    );
    when(
      () => repository.getFavorites(_uid),
    ).thenAnswer((_) async => <FavoriteItem>[item]);
    when(
      () => repository.remove(_uid, 3),
    ).thenThrow(const Failure('تعذّر تحديث المفضّلة.'));

    final FavoritesCubit cubit = cubitWith(repository);
    addTearDown(cubit.close);

    await cubit.load();
    await tester.pumpWidget(_host(cubit));
    await tester.pump();
    expect(find.text('حقيبة جلد'), findsOneWidget);

    await tester.tap(find.byTooltip('إزالة من المفضّلة'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // العنصر يعود بعد التراجع (Requirement 14.7) والمحتوى يبقى معروضًا
    // والرسالة تظهر في SnackBar (Requirement 15.7).
    expect(find.text('حقيبة جلد'), findsOneWidget);
    expect(
      find.widgetWithText(SnackBar, 'تعذّر تحديث المفضّلة.'),
      findsOneWidget,
    );
  });
}
