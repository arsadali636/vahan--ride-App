import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../design_system/components/app_empty_view.dart';
import '../../../../design_system/components/app_error_view.dart';
import '../../../../design_system/components/app_loader.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../bloc/doctor_network_bloc.dart';
import '../bloc/doctor_network_event.dart';
import '../bloc/doctor_network_state.dart';
import '../widgets/doctor_search_bar.dart';
import '../widgets/doctor_search_filters.dart';
import '../widgets/doctor_search_result_card.dart';

/// Doctor discovery screen: search, filter and paginated results.
///
/// Owns a [DoctorNetworkBloc]. Supports pull-to-refresh, infinite scroll and
/// tap-through to a doctor's public profile.
class DoctorSearchPage extends StatefulWidget {
  /// Optional override for tests; defaults to the DI-provided instance.
  final DoctorNetworkBloc? bloc;

  const DoctorSearchPage({super.key, this.bloc});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<DoctorNetworkBloc>().add(
        const DoctorSearchLoadMoreRequested(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DoctorNetworkBloc>(
      create: (_) =>
          widget.bloc ?? DependencyInjection.get<DoctorNetworkBloc>(),
      child: Builder(
        builder: (context) {
          final bloc = context.read<DoctorNetworkBloc>();
          return Scaffold(
            appBar: AppBar(title: const Text('Find doctors')),
            body: Column(
              children: [
                DoctorSearchBar(
                  controller: _queryController,
                  onChanged: (value) =>
                      bloc.add(DoctorSearchQueryChanged(value)),
                ),
                DoctorSearchFilterBar(
                  filters: context.select(
                    (DoctorNetworkBloc b) => b.state.filters,
                  ),
                  onResult: (result) {
                    if (result.clearedAll) {
                      _queryController.clear();
                      bloc.add(const DoctorSearchCleared());
                    } else {
                      bloc.add(DoctorSearchFiltersChanged(result.filters));
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                Expanded(
                  child: BlocConsumer<DoctorNetworkBloc, DoctorNetworkState>(
                    listener: (context, state) {
                      if (state.status == DoctorNetworkStatus.loaded &&
                          state.error != null) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text(state.error!.message)),
                          );
                      }
                    },
                    builder: (context, state) => _SearchBody(
                      state: state,
                      scrollController: _scrollController,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  final DoctorNetworkState state;
  final ScrollController scrollController;

  const _SearchBody({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DoctorNetworkBloc>();

    switch (state.status) {
      case DoctorNetworkStatus.initial:
        return const AppEmptyView(
          title: 'Discover doctors',
          message:
              'Search by name, specialty or location to build your '
              'professional network.',
          icon: Icons.people_alt_outlined,
        );
      case DoctorNetworkStatus.loading:
        return const AppLoader(label: 'Finding doctors…');
      case DoctorNetworkStatus.failure:
        return AppErrorView(
          title: 'Could not search doctors',
          message: state.error?.message,
          onRetry: () => bloc.add(const DoctorSearchStarted()),
        );
      case DoctorNetworkStatus.empty:
        return const AppEmptyView(
          title: 'No doctors found',
          message: 'Try changing your search or filters.',
          icon: Icons.search_off_rounded,
        );
      case DoctorNetworkStatus.loaded:
      case DoctorNetworkStatus.loadingMore:
      case DoctorNetworkStatus.refreshing:
        return RefreshIndicator(
          onRefresh: () async {
            bloc.add(const DoctorSearchRefreshRequested());
            await bloc.stream.firstWhere(
              (s) => s.status != DoctorNetworkStatus.refreshing,
            );
          },
          child: ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: state.results.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.results.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                );
              }
              final result = state.results[index];
              return DoctorSearchResultCard(
                key: ValueKey('doctor-${result.id}'),
                result: result,
                onTap: () =>
                    context.push(AppRouter.doctorPublicProfilePath(result.id)),
              );
            },
          ),
        );
    }
  }
}
