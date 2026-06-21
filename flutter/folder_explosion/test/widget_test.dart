import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:folder_explosion/main.dart';

void main() {
  testWidgets('folder toggles between closed and open states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FolderExplosionApp());

    expect(find.text('Folder Explosion'), findsOneWidget);
    expect(find.byKey(const Key('folder-status-text')), findsOneWidget);
    expect(find.text('Assets'), findsOneWidget);
    expect(find.byKey(const Key('folder-explosion-toggle')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('folder-status-text'))).data,
      'CLOSED',
    );

    await tester.tap(find.byKey(const Key('folder-explosion-toggle')));
    await tester.pumpAndSettle(const Duration(milliseconds: 1400));

    expect(
      tester.widget<Text>(find.byKey(const Key('folder-status-text'))).data,
      'OPEN',
    );
    expect(find.text('Invoice.pdf'), findsOneWidget);

    await tester.tap(find.byKey(const Key('folder-explosion-toggle')));
    await tester.pumpAndSettle(const Duration(milliseconds: 1200));

    expect(
      tester.widget<Text>(find.byKey(const Key('folder-status-text'))).data,
      'CLOSED',
    );
  });
}
