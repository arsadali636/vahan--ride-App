import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/features/organizations/presentation/pages/organizations_page.dart';

void main() {
  group('OrganizationsPage', () {
    testWidgets('renders the organizations chrome with an honest state',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: OrganizationsPage()));

      expect(find.text('Organizations'), findsOneWidget);
      // No fake healthcare organizations are rendered — the backend contract
      // gap is surfaced instead of pretending an organization feature exists.
      expect(
        find.text('Healthcare organizations are not available yet'),
        findsOneWidget,
      );
      expect(
        find.textContaining('organization endpoints are not published'),
        findsOneWidget,
      );
    });
  });
}
