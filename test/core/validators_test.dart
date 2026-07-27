import 'package:flutter_test/flutter_test.dart';
import 'package:shopify/core/utils/validators.dart';

void main() {
  group('Validators.name', () {
    test('يقبل اسمًا غير فارغ', () {
      expect(Validators.name('سارة'), isNull);
    });

    test('يرفض القيمة الفارغة أو المسافات فقط أو null', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name('   '), isNotNull);
      expect(Validators.name(null), isNotNull);
    });
  });

  group('Validators.phone', () {
    test('يقبل 7 و 15 رقمًا و+ في البداية', () {
      expect(Validators.phone('1234567'), isNull);
      expect(Validators.phone('123456789012345'), isNull);
      expect(Validators.phone('+201234567890'), isNull);
    });

    test('يرفض ما هو أقصر من 7 أو أطول من 15 أو يحتوي محارف غير رقمية', () {
      expect(Validators.phone('123456'), isNotNull);
      expect(Validators.phone('1234567890123456'), isNotNull);
      expect(Validators.phone('012-345-6789'), isNotNull);
      expect(Validators.phone('++1234567'), isNotNull);
      expect(Validators.phone(null), isNotNull);
    });
  });

  group('Validators.email', () {
    test('يقبل بريدًا مطابقًا للنمط', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('يرفض البريد بدون @ أو بدون نقطة أو بمسافات', () {
      expect(Validators.email('userexample.com'), isNotNull);
      expect(Validators.email('user@example'), isNotNull);
      expect(Validators.email('us er@example.com'), isNotNull);
      expect(Validators.email('a@b@c.com'), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });
  });

  group('Validators.password', () {
    test('يقبل 6 محارف أو أكثر', () {
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('a very long password'), isNull);
    });

    test('يرفض أقل من 6 محارف', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password(''), isNotNull);
      expect(Validators.password(null), isNotNull);
    });
  });
}
