import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_switcher/main.dart';

void main() {
  testWidgets('toggles the animated day night switcher', (tester) async {
    await tester.pumpWidget(const ThemeSwitcherApp());

    expect(find.text('Morning'), findsOneWidget);
    expect(find.byType(ThemeSwitchControl), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 850));
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();

    expect(find.text('Midnight'), findsOneWidget);
    expect(find.text('Dark mode with a sky.'), findsOneWidget);

    await tester.drag(find.byType(ThemeSwitchControl), const Offset(-260, 0));
    await tester.pump(const Duration(milliseconds: 820));

    expect(find.text('Morning'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
