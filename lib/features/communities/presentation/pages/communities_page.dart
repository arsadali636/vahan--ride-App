import 'package:flutter/material.dart';

import '../../../../design_system/components/app_empty_view.dart';

/// Specialty communities screen.
///
/// API contract gap — the current OpenAPI contract defines no community
/// endpoints (no community list, detail, search, join/leave, members or
/// posts). Nothing is fabricated here: the page renders an honest unavailable
/// state instead of hardcoded communities, fake member counts or pretend join
/// state. The data layer, BLoC and community widgets are intentionally not
/// created until the backend documents the community contract, so nothing
/// implies a working communities feature.
class CommunitiesPage extends StatelessWidget {
  const CommunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communities')),
      body: const AppEmptyView(
        title: 'Specialty communities are not available yet',
        message: 'The community endpoints are not published in the backend '
            'contract yet. Discovering, joining and participating in '
            'specialty communities will appear here once the communities '
            'API is available.',
        icon: Icons.forum_outlined,
      ),
    );
  }
}
