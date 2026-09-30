import 'package:flutter_test/flutter_test.dart';
import 'package:i24h_native/app.dart';

void main() {
  testWidgets('I24H démarre sur l onboarding', (tester) async {
    await tester.pumpWidget(const I24HApp());
    expect(find.text('Une radio qui vous accompagne'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });
}
