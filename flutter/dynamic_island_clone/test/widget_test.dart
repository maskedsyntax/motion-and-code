import 'package:dynamic_island_clone/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows and expands the dynamic island demo', (tester) async {
    await tester.pumpWidget(const DynamicIslandApp());

    expect(find.text('Dynamic Lagoon'), findsOneWidget);
    expect(find.byIcon(Icons.flight_takeoff_rounded), findsOneWidget);

    await tester.tap(find.byType(DynamicIslandDemo));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Flight tracking'), findsOneWidget);
    expect(find.text('SFO to NYC - boarding now'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);
  });
}
