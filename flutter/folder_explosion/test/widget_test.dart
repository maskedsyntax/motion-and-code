import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:folder_explosion/main.dart';

void main() {
  testWidgets('folder toggles between closed and open states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: FolderExplosionDemo(autoPlay: false)),
    );

    expect(find.byKey(const Key('folder-status-text')), findsOneWidget);
    expect(find.text('Assets'), findsOneWidget);
    expect(find.byKey(const Key('folder-explosion-toggle')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('folder-status-text'))).data,
      'CLOSED',
    );

    await tester.tap(find.byKey(const Key('folder-explosion-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2900));

    expect(
      tester.widget<Text>(find.byKey(const Key('folder-status-text'))).data,
      'OPEN',
    );
    expect(find.text('Invoice.pdf'), findsOneWidget);

    await tester.tap(find.byKey(const Key('folder-explosion-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));

    expect(
      tester.widget<Text>(find.byKey(const Key('folder-status-text'))).data,
      'CLOSED',
    );
  });

  testWidgets('auto loop opens folder without user input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: FolderExplosionDemo(autoPlay: true)),
    );

    expect(
      tester.widget<Text>(find.byKey(const Key('folder-status-text'))).data,
      'CLOSED',
    );

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 2800));

    expect(
      tester.widget<Text>(find.byKey(const Key('folder-status-text'))).data,
      'OPEN',
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
