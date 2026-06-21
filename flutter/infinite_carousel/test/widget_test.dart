import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_carousel/main.dart';

void main() {
  testWidgets('loops through carousel cards', (tester) async {
    await tester.pumpWidget(const InfiniteCarouselApp());

    expect(find.text('INFINITE'), findsOneWidget);
    expect(find.text('Aurora'), findsWidgets);
    expect(find.byKey(const Key('infinite-carousel')), findsOneWidget);
    expect(
      tester
          .widget<PageView>(find.byKey(const Key('infinite-carousel')))
          .clipBehavior,
      Clip.none,
    );

    await tester.drag(
      find.byKey(const Key('infinite-carousel')),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Lunar'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
