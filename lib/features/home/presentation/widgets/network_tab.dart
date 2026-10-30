import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/suggested_doctor.dart';
import '../../domain/entities/urgent_job.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// Network tab: dynamic doctor discovery and urgent job openings from API.
class NetworkTab extends StatelessWidget {
  const NetworkTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.readOrNull<HomeBloc>() != null) {
      return const _NetworkTabView();
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
      child: const _NetworkTabView(),
    );
  }
}

class _NetworkTabView extends StatefulWidget {
  const _NetworkTabView();

  @override
  State<_NetworkTabView> createState() => _NetworkTabViewState();
}

class _NetworkTabViewState extends State<_NetworkTabView> {
  final Set<String> _connectedDoctorIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        title: Text(
          'My Network',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: AppTypography.wBold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading && state.data == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == HomeStatus.failure && state.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      state.error?.message ?? 'Failed to load network data',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(const HomeStarted());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final homeData = state.data;
          final urgentJobs = homeData?.urgentJobs ?? const [];
          final suggestedDoctors = homeData?.suggestedDoctors ?? const [];

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeRefreshRequested());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                // ── 1. Dynamic Urgent Openings Section ───────────────────
                if (urgentJobs.isNotEmpty) ...[
                  _UrgentOpeningsCard(
                    jobs: urgentJobs,
                    onSeeAllPressed: () {
                      // Navigate to Jobs search or view all
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                // ── 2. Dynamic People You May Know Section ────────────────
                if (suggestedDoctors.isNotEmpty) ...[
                  _PeopleYouMayKnowCard(
                    doctors: suggestedDoctors,
                    connectedDoctorIds: _connectedDoctorIds,
                    onConnectPressed: (doctor) {
                      setState(() {
                        _connectedDoctorIds.add(doctor.id);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Connection request sent to ${doctor.fullName}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onSeeAllPressed: () {
                      context.push(AppRouter.doctorNetworkRoute);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                // ── 3. Manage Network Banner ──────────────────────────────
                _ManageNetworkCard(
                  onTap: () {
                    context.push(AppRouter.doctorNetworkRoute);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Dynamic Urgent Openings Section Container matching Image 2 UI.
class _UrgentOpeningsCard extends StatelessWidget {
  final List<UrgentJob> jobs;
  final VoidCallback onSeeAllPressed;

  const _UrgentOpeningsCard({
    required this.jobs,
    required this.onSeeAllPressed,
  });

  String _formatSalary(UrgentJob job) {
    if (job.salaryMin > 0 && job.salaryMax > 0) {
      return '₹${job.salaryMin}.00 - ₹${job.salaryMax}.00';
    } else if (job.salaryMin > 0) {
      return '₹${job.salaryMin}.00';
    } else if (job.salaryMax > 0) {
      return '₹${job.salaryMax}.00';
    }
    return 'Competitive Salary';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Section Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                const Text('🚨', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Urgent Openings',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: AppTypography.wBold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onSeeAllPressed,
                  child: Text(
                    'See all',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppTypography.wSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── Dynamic Jobs List ───────────────────────────────────
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jobs.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
            itemBuilder: (context, index) {
              final job = jobs[index];
              final salaryText = _formatSalary(job);
              final typeText = job.jobTypeDisplay.isNotEmpty
                  ? job.jobTypeDisplay
                  : 'Full Time';

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hospital Icon / Logo Square Box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Job Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: AppTypography.wBold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.hospitalName,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: AppTypography.wMedium,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$salaryText • $typeText',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Urgent Chip Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔴', style: TextStyle(fontSize: 8)),
                                const SizedBox(width: 4),
                                Text(
                                  'Urgent',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: const Color(0xFFDC2626),
                                    fontWeight: AppTypography.wBold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Dynamic People You May Know Container matching Image 2 UI.
class _PeopleYouMayKnowCard extends StatelessWidget {
  final List<SuggestedDoctor> doctors;
  final Set<String> connectedDoctorIds;
  final ValueChanged<SuggestedDoctor> onConnectPressed;
  final VoidCallback onSeeAllPressed;

  const _PeopleYouMayKnowCard({
    required this.doctors,
    required this.connectedDoctorIds,
    required this.onConnectPressed,
    required this.onSeeAllPressed,
  });

  String _getLocationString(SuggestedDoctor doctor) {
    final loc = doctor.location;
    if (loc.containsKey('city') &&
        loc['city'] != null &&
        loc['city'].toString().isNotEmpty) {
      return loc['city'].toString();
    }
    if (loc.containsKey('state') &&
        loc['state'] != null &&
        loc['state'].toString().isNotEmpty) {
      return loc['state'].toString();
    }
    return 'India';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Section Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                const Text('👥', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'People you may know',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: AppTypography.wBold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onSeeAllPressed,
                  child: Text(
                    'See all',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppTypography.wSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── Dynamic Doctors List ────────────────────────────────
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: doctors.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              final isConnected = connectedDoctorIds.contains(doctor.id);
              final doctorName = doctor.fullName.startsWith('Dr.')
                  ? doctor.fullName
                  : 'Dr. ${doctor.fullName}';
              final location = _getLocationString(doctor);
              final headline = doctor.headline.isNotEmpty
                  ? doctor.headline
                  : 'Medical Professional';
              final expYears = doctor.experienceYears > 0
                  ? ' • ${doctor.experienceYears} yrs'
                  : '';

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circle Doctor Avatar / Initials
                    DoctorAvatar(
                      photoUrl: UrlUtils.resolveUrl(doctor.photo),
                      firstName: doctor.initials.isNotEmpty
                          ? doctor.initials
                          : doctor.fullName,
                      size: 48,
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Doctor Details Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctorName,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: AppTypography.wBold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$headline$expYears',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            location,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),

                    // + Connect Pill Button
                    OutlinedButton(
                      onPressed: isConnected
                          ? null
                          : () => onConnectPressed(doctor),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: isConnected
                              ? AppColors.border
                              : AppColors.primary,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isConnected ? 'Pending' : '+ Connect',
                        style: AppTypography.labelMedium.copyWith(
                          color: isConnected
                              ? AppColors.textDisabled
                              : AppColors.primary,
                          fontWeight: AppTypography.wBold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Manage Network Banner.
class _ManageNetworkCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ManageNetworkCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.people_alt_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          'Manage my network',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: AppTypography.wBold,
          ),
        ),
        subtitle: Text(
          'Search and connect with doctors across India',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
