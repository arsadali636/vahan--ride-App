import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/hospital_avatar.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/components/search_field.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/urgent_job.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// Jobs tab: opportunities, saved roles and discovery.
class JobsTab extends StatefulWidget {
  const JobsTab({super.key});

  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.readOrNull<HomeBloc>() != null) {
      return _buildScaffold(context);
    }
    return BlocProvider(
      create: (context) {
        if (DependencyInjection.instance.isRegistered<HomeBloc>()) {
          return DependencyInjection.instance<HomeBloc>()
            ..add(const HomeStarted());
        }
        return HomeBloc(
          getHomeData: GetHomeData(
            HomeRepositoryImpl(
              remoteDataSource: HomeRemoteDataSourceImpl(
                apiClient: DependencyInjection.instance<ApiClient>(),
              ),
            ),
          ),
        )..add(const HomeStarted());
      },
      child: Builder(builder: _buildScaffold),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opportunities')),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeRefreshRequested());
            },
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state.status == HomeStatus.loading ||
        state.status == HomeStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HomeStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              state.error?.message ?? 'Failed to load jobs',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () {
                context.read<HomeBloc>().add(const HomeStarted());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final data = state.data;
    if (data == null) {
      return const Center(child: Text('No data available'));
    }

    final urgentJobs = data.urgentJobs;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SearchField(
            controller: _queryController,
            hint: 'Search jobs by title, skill or hospital',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _OpenToWorkCard(),
        const SizedBox(height: AppSpacing.sm),
        if (urgentJobs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xl,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.work_outline_rounded,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No urgent jobs available',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Check back later for new opportunities.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final job in urgentJobs) _JobCard(job: job),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _OpenToWorkCard extends StatelessWidget {
  const _OpenToWorkCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppCard(
        hasShadow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Open to work', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Share your availability with recruiters and hospitals.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(onPressed: () {}, child: const Text('Add to profile')),
          ],
        ),
      ),
    );
  }
}

String _formatPostedAt(String isoString) {
  if (isoString.isEmpty) return '';
  try {
    final date = DateTime.parse(isoString);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  } catch (_) {
    return isoString;
  }
}

class _JobCard extends StatelessWidget {
  final UrgentJob job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final locationLabel = job.location.values
        .whereType<String>()
        .where((v) => v.isNotEmpty)
        .join(', ');

    return AppCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HospitalAvatar(
                logoUrl: job.hospitalLogo,
                hospitalName: job.hospitalName,
                size: 48,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: AppTypography.titleSmall,
                          ),
                        ),
                        if (job.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              'Urgent',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: AppTypography.wSemiBold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(job.hospitalName, style: AppTypography.bodyMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      [
                        if (locationLabel.isNotEmpty) locationLabel,
                        job.jobTypeDisplay.isNotEmpty
                            ? job.jobTypeDisplay
                            : job.jobType,
                        _formatPostedAt(job.postedAt),
                      ].where((s) => s.isNotEmpty).join(' \u2022 '),
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Save job',
                icon: const Icon(Icons.bookmark_outline_rounded),
                color: AppColors.textSecondary,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(label: 'Apply', onPressed: () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
