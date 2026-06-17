import 'package:app_store_download_button/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('runs the App Store download button states', (tester) async {
    await tester.pumpWidget(const AppStoreDownloadApp());

    expect(find.text('FrameLab'), findsOneWidget);
    expect(find.text('GET'), findsOneWidget);

    await tester.tap(find.byType(DownloadButtonDemo));
    await tester.pump(const Duration(milliseconds: 720));

    expect(find.byType(DownloadButton), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('OPEN'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
