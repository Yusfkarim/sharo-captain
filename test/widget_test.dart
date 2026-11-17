import 'package:flutter_test/flutter_test.dart';
import 'package:sharo_captain/main.dart';

void main() {
  testWidgets('SharoCaptainApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SharoCaptainApp());
    expect(find.byType(SharoCaptainApp), findsOneWidget);
  });
}
