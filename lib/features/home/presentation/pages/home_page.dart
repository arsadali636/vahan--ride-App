import 'package:flutter/material.dart';

import '../../../../design_system/components/app_bottom_sheet.dart';
import '../widgets/account_tab.dart';
import '../widgets/feed_tab.dart';
import '../widgets/jobs_tab.dart';
import '../widgets/main_navigation_bar.dart';
import '../widgets/network_tab.dart';
import '../widgets/post_composer_sheet.dart';

/// Main application shell after sign-in.
///
/// Hosts the four primary destinations (Home feed, Network, Jobs, Me) in an
/// [IndexedStack] and drives navigation through the custom LinkedIn-style
/// bottom bar in [MainNavigationBar]. The centered Post action opens the
/// [PostComposerSheet]. No drawer is used anywhere in the app.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MainTab _selected = MainTab.home;

  void _openComposer() {
    AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      child: const PostComposerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selected.index,
        children: const [
          FeedTab(),
          NetworkTab(),
          JobsTab(),
          AccountTab(),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        selected: _selected,
        onTabSelected: (tab) => setState(() => _selected = tab),
        onPostPressed: _openComposer,
      ),
    );
  }
}
