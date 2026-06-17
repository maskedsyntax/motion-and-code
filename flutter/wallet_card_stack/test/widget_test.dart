import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_card_stack/main.dart';

void main() {
  testWidgets('expands wallet stack and opens a card', (tester) async {
    await tester.pumpWidget(const WalletCardStackApp());

    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Motion Bank'), findsOneWidget);

    await tester.tap(find.byType(WalletCardStackDemo));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Pixel Credit'), findsOneWidget);
    expect(find.text('Studio Pass'), findsOneWidget);

    await tester.tap(find.text('Pixel Credit'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Figma'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
