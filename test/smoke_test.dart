import 'package:flutter_test/flutter_test.dart';
import 'package:i24h_native/app.dart';

void main() {
  testWidgets('I24H démarre sur le premier écran d’onboarding', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const I24HApp());
    await tester.pumpAndSettle();

    expect(find.text('Votre radio.\nVotre moment.'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });
}
