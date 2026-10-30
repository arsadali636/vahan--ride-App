import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/features/communities/presentation/pages/communities_page.dart';

void main() {
  group('CommunitiesPage', () {
    testWidgets('renders the communities chrome with an honest state', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: CommunitiesPage()));

      expect(find.text('Communities'), findsOneWidget);
      // No fake communities are rendered — the backend contract gap is
      // surfaced instead of pretending a communities feature exists.
      expect(
        find.text('Specialty communities are not available yet'),
        findsOneWidget,
      );
      expect(
        find.textContaining('community endpoints are not published'),
        findsOneWidget,
      );
    });
  });
}
