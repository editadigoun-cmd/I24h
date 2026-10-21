import 'package:flutter_test/flutter_test.dart';
import 'package:i24h_native/app.dart';

void main() {
  testWidgets('I24H affiche son onboarding', (tester) async {
    await tester.pumpWidget(const I24HApp());
    expect(find.text('La présence qui vous accompagne.'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
    expect(find.text('J’ai déjà un compte — Se connecter'), findsOneWidget);
  });

  testWidgets('un visiteur peut entrer dans I24H sans compte', (tester) async {
    await tester.pumpWidget(const I24HApp());
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(find.text('Un moment de paix,'), findsOneWidget);
    expect(find.text('Regarder le direct'), findsOneWidget);
  });
}
