import 'package:flutter_test/flutter_test.dart';
import 'package:shopify/core/utils/formatters.dart';

void main() {
  final pricePattern = RegExp(r'^\$\d+\.\d{2}$');
  final ratingPattern = RegExp(r'^-?\d+\.\d$');

  group('Formatters.price', () {
    test('ينسّق بمنزلتين عشريتين وبادئة عملة', () {
      expect(Formatters.price(1234.5), r'$1234.50');
      expect(Formatters.price(0), r'$0.00');
      expect(Formatters.price(9.999), r'$10.00');
    });

    test('يعيد قيمة مطابقة للنمط مع السالب وغير المنتهي والكبير', () {
      for (final value in <double>[
        -1.5,
        double.nan,
        double.infinity,
        double.negativeInfinity,
        1e21,
        1e30,
      ]) {
        expect(
          Formatters.price(value),
          matches(pricePattern),
          reason: '$value',
        );
      }
      expect(Formatters.price(-1.5), r'$0.00');
    });
  });

  group('Formatters.rating', () {
    test('ينسّق بمنزلة عشرية واحدة بالضبط', () {
      // 4.55 في تمثيل IEEE 754 يُخزَّن أقل قليلًا من 4.55، لذا toStringAsFixed(1) ينتج '4.5'
      expect(Formatters.rating(4.55), '4.5');
      expect(Formatters.rating(4), '4.0');
      expect(Formatters.rating(0), '0.0');
    });

    test('لا يقصّ القيم خارج النطاق ويتعامل مع غير المنتهي والكبير', () {
      expect(Formatters.rating(7.34), '7.3');
      expect(Formatters.rating(double.nan), '0.0');
      expect(Formatters.rating(double.infinity), '0.0');
      expect(Formatters.rating(1e22), matches(ratingPattern));
      expect(Formatters.rating(-2.25), matches(ratingPattern));
    });
  });
}
