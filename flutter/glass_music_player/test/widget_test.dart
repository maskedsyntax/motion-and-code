import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glass_music_player/main.dart';

void main() {
  testWidgets('play button toggles playback state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GlassMusicPlayerDemo(autoPlay: false)),
    );

    expect(find.byKey(const Key('glass-player-toggle')), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('glass-player-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('glass-player-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('auto loop starts playback without user input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: GlassMusicPlayerDemo(autoPlay: true)),
    );

    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
