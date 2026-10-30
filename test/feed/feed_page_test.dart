import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/features/feed/presentation/pages/feed_page.dart';

void main() {
  group('FeedPage', () {
    testWidgets('renders the professional feed chrome with an honest state', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: FeedPage()));

      expect(find.text('Professional feed'), findsOneWidget);
      // No fake posts are rendered — the backend contract gap is surfaced
      // instead of pretending a feed exists.
      expect(
        find.text('Professional feed is not available yet'),
        findsOneWidget,
      );
      expect(
        find.textContaining('feed endpoints are not published'),
        findsOneWidget,
      );
    });
  });
}
