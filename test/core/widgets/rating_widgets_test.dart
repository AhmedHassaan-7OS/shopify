import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopify/core/theme/app_theme.dart';
import 'package:shopify/core/widgets/favorite_button.dart';
import 'package:shopify/core/widgets/rating_badge.dart';
import 'package:shopify/core/widgets/rating_stars.dart';
import 'package:shopify/data/models/product_model.dart';
import 'package:shopify/data/repositories/favorites_repository.dart';
import 'package:shopify/data/services/auth_service.dart';
import 'package:shopify/logic/favorites/favorites_cubit.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockUser extends Mock implements User {}

const String _uid = 'uid-1';

const ProductModel _product = ProductModel(
  id: 7,
  title: 'iPhone 14 Pro',
  description: 'وصف',
  category: 'smartphones',
  price: 999.99,
  rating: 4.7,
  thumbnail: 'https://example.com/t.png',
  images: <String>[],
  brand: 'Apple',
  stock: 5,
);

/// يغلّف [child] بثيم التطبيق داخل `Scaffold` لاختباره.
Widget _wrap(Widget child, {TextDirection direction = TextDirection.rtl}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: Directionality(
        textDirection: direction,
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('RatingStars', () {
    for (final double value in <double>[-3, 0, 2.4, 2.5, 4.7, 5, 9]) {
      testWidgets('يعرض 5 أيقونات دائمًا عند التقييم $value', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_wrap(RatingStars(rating: value)));

        expect(find.byType(Icon), findsNWidgets(RatingStars.starCount));
      });
    }

    testWidgets('يعرض النص الرقمي بمنزلة عشرية واحدة', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const RatingStars(rating: 4.66)));

      expect(find.text('4.7'), findsOneWidget);
    });

    test('عدد النجوم الممتلئة غير تنازلي ومقصوص داخل 0..5', () {
      expect(RatingStars.filledStars(-10), 0);
      expect(RatingStars.filledStars(0), 0);
      expect(RatingStars.filledStars(2.9), 2);
      expect(RatingStars.filledStars(3), 3);
      expect(RatingStars.filledStars(99), RatingStars.starCount);
      expect(RatingStars.filledStars(double.nan), 0);

      int previous = 0;
      for (double v = -2; v <= 8; v += 0.25) {
        final int current = RatingStars.filledStars(v);
        expect(current, greaterThanOrEqualTo(previous));
        previous = current;
      }
    });

    test('نصف النجمة يظهر من الجزء الكسري 0.5 فقط وليس بعد آخر نجمة', () {
      expect(RatingStars.hasHalfStar(2.49), isFalse);
      expect(RatingStars.hasHalfStar(2.5), isTrue);
      expect(RatingStars.hasHalfStar(5), isFalse);
      expect(RatingStars.hasHalfStar(7.8), isFalse);
    });
  });

  group('RatingBadge', () {
    testWidgets('يعرض نجمة واحدة والرقم بمنزلة عشرية واحدة', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const RatingBadge(rating: 4.25)));

      expect(find.byType(Icon), findsOneWidget);
      expect(find.text('4.3'), findsOneWidget);
    });
  });

  group('FavoriteButton', () {
    late _MockAuthService auth;
    late FakeFirebaseFirestore firestore;
    late FavoritesCubit cubit;

    setUp(() {
      auth = _MockAuthService();
      final _MockUser user = _MockUser();
      when(() => user.uid).thenReturn(_uid);
      when(() => auth.currentUser).thenReturn(user);

      firestore = FakeFirebaseFirestore();
      cubit = FavoritesCubit(
        favoritesRepository: FavoritesRepository(firestore: firestore),
        authService: auth,
      );
    });

    tearDown(() => cubit.close());

    testWidgets('الضغط يبدّل شكل القلب ويكتب وثيقة المفضّلة', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          BlocProvider<FavoritesCubit>.value(
            value: cubit,
            child: const FavoriteButton(product: _product),
          ),
        ),
      );

      double fill() => tester.widget<Icon>(find.byType(Icon)).fill ?? 0;

      expect(fill(), 0);

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(fill(), 1);
      expect(cubit.isFavorite(_product.id), isTrue);

      final snapshot = await firestore
          .collection('users')
          .doc(_uid)
          .collection('favorites')
          .get();
      expect(snapshot.docs.map((doc) => doc.id), <String>['7']);
    });

    testWidgets('الضغط مرتين يعيد القلب فارغًا ويحذف الوثيقة', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          BlocProvider<FavoritesCubit>.value(
            value: cubit,
            child: const FavoriteButton(product: _product),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(tester.widget<Icon>(find.byType(Icon)).fill ?? 0, 0);
      expect(cubit.isFavorite(_product.id), isFalse);

      final snapshot = await firestore
          .collection('users')
          .doc(_uid)
          .collection('favorites')
          .get();
      expect(snapshot.docs, isEmpty);
    });
  });
}
