import 'package:flutter_test/flutter_test.dart';
import 'package:shopify/core/utils/debouncer.dart';

void main() {
  const short = Duration(milliseconds: 40);
  const afterShort = Duration(milliseconds: 120);

  test('المدة الافتراضية 400 مللي ثانية', () {
    expect(Debouncer().delay, const Duration(milliseconds: 400));
  });

  test('ينفّذ آخر عملية فقط بعد سكون الإدخال', () async {
    final debouncer = Debouncer(delay: short);
    final calls = <int>[];

    debouncer.run(() => calls.add(1));
    debouncer.run(() => calls.add(2));
    expect(calls, isEmpty);
    expect(debouncer.isActive, isTrue);

    await Future<void>.delayed(afterShort);
    expect(calls, [2]);
    expect(debouncer.isActive, isFalse);

    debouncer.dispose();
  });

  test('cancel و dispose يمنعان التنفيذ', () async {
    final debouncer = Debouncer(delay: short);
    var called = false;

    debouncer.run(() => called = true);
    debouncer.cancel();
    await Future<void>.delayed(afterShort);
    expect(called, isFalse);

    debouncer.run(() => called = true);
    debouncer.dispose();
    await Future<void>.delayed(afterShort);
    expect(called, isFalse);
    expect(debouncer.isActive, isFalse);
  });
}
