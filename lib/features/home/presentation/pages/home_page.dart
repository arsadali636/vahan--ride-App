import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection.dart';
import '../../../../core/api/api_client.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/components/app_bottom_sheet.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../widgets/account_tab.dart';
import '../widgets/feed_tab.dart';
import '../widgets/jobs_tab.dart';
import '../widgets/main_navigation_bar.dart';
import '../widgets/network_tab.dart';
import '../widgets/post_composer_sheet.dart';

/// Main application shell after sign-in.
///
/// Hosts the four primary destinations (Home feed, Network, Jobs, Profile) in an
/// [IndexedStack] and drives navigation through the custom DocConnect Pro
/// floating navigation bar in [MainNavigationBar].
///
/// Scopes a single [HomeBloc] across all tabs to eliminate redundant dashboard
/// requests and ensure synchronized data across Feed, Network and Jobs tabs.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MainTab _selected = MainTab.home;
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = DependencyInjection.instance.isRegistered<HomeBloc>()
        ? DependencyInjection.instance<HomeBloc>()
        : HomeBloc(
            getHomeData:
                DependencyInjection.instance.isRegistered<GetHomeData>()
                ? DependencyInjection.instance<GetHomeData>()
                : GetHomeData(
                    HomeRepositoryImpl(
                      remoteDataSource: HomeRemoteDataSourceImpl(
                        apiClient: DependencyInjection.instance<ApiClient>(),
                      ),
                    ),
                  ),
          );
    _homeBloc.add(const HomeStarted());
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  void _openComposer() {
    AppBottomSheet.show(
      context: context,
      isScrollControlled: true,
      child: const PostComposerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>.value(
      value: _homeBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _selected.index,
          children: const [FeedTab(), NetworkTab(), JobsTab(), AccountTab()],
        ),
        bottomNavigationBar: MainNavigationBar(
          selected: _selected,
          onTabSelected: (tab) => setState(() => _selected = tab),
          onPostPressed: _openComposer,
        ),
      ),
    );
  }
}
