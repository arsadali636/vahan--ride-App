import 'package:flutter/material.dart';

import '../../../../design_system/components/app_empty_view.dart';

/// Healthcare organization browsing screen.
///
/// API contract gap — the current OpenAPI contract defines no doctor-facing
/// organization endpoints (no organization list, search, detail or public
/// profile). The only hospital operations present (`/api/v1/hospitals/me/*`,
/// `/api/v1/hospitals/register/`) are hospital-admin self-management with
/// undocumented responses; they belong to the backend/Django CRM side and are
/// intentionally not implemented in the mobile app. Nothing is fabricated
/// here: the page renders an honest unavailable state instead of hardcoded
/// hospitals, fake member counts or pretend verification badges. The data
/// layer, BLoC and organization widgets are intentionally not created until
/// the backend documents the doctor-facing organization contract, so nothing
/// implies a working organization feature.
class OrganizationsPage extends StatelessWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizations')),
      body: const AppEmptyView(
        title: 'Healthcare organizations are not available yet',
        message:
            'The doctor-facing organization endpoints are not published '
            'in the backend contract yet. Discovering and viewing healthcare '
            'organizations will appear here once the organizations API is '
            'available.',
        icon: Icons.local_hospital_outlined,
      ),
    );
  }
}
