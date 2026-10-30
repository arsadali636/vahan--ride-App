import 'package:flutter/material.dart';

import '../../../../design_system/components/app_empty_view.dart';

/// Professional feed screen.
///
/// API contract gap — the current OpenAPI contract defines no feed endpoints
/// (no feed list, posts, comments, reactions or media upload). Nothing is
/// fabricated here: the page renders an honest unavailable state instead of
/// hardcoded posts, fake counts or pretend success. The data layer, BLoC and
/// post/composer/comment widgets are intentionally not created until the
/// backend documents the feed contract, so nothing implies a working feed.
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional feed')),
      body: const AppEmptyView(
        title: 'Professional feed is not available yet',
        message:
            'The feed endpoints are not published in the backend '
            'contract yet. Posts, comments and reactions will appear here '
            'once the feed API is available.',
        icon: Icons.article_outlined,
      ),
    );
  }
}
