import 'package:flutter_test/flutter_test.dart';

import 'package:flame_jam_2026/main.dart';

void main() {
  testWidgets('game screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const GameScreen());

    expect(find.byType(GameScreen), findsOneWidget);
  });
}
