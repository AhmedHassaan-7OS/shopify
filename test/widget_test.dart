import 'package:flutter_test/flutter_test.dart';

import 'package:shopify/app.dart';

void main() {
  testWidgets('ShopifyApp يقلع ويبني شجرة الويدجتس', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ShopifyApp());

    expect(find.text('ESTUDIO'), findsOneWidget);
  });
}
