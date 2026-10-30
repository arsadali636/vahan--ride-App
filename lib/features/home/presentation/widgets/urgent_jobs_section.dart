import 'package:flutter/material.dart';

import '../../../../core/utils/url_utils.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/components/hospital_avatar.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/urgent_job.dart';

/// Renders urgent jobs returned by `GET /api/v1/feed/home/`.
class UrgentJobsSection extends StatelessWidget {
  final List<UrgentJob> jobs;
  final ValueChanged<UrgentJob>? onJobPressed;

  const UrgentJobsSection({super.key, required this.jobs, this.onJobPressed});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Urgent Opportunities',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.wBold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: jobs.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final job = jobs[index];
              final resolvedLogo = UrlUtils.resolveUrl(job.hospitalLogo);
              final locationLabel = job.location.values
                  .whereType<String>()
                  .where((v) => v.isNotEmpty)
                  .join(', ');

              return InkWell(
                onTap: () => onJobPressed?.call(job),
                borderRadius: AppRadius.borderLg,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      HospitalAvatar(
                        logoUrl: resolvedLogo,
                        hospitalName: job.hospitalName,
                        size: 40,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: AppTypography.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              job.hospitalName,
                              style: AppTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              [
                                if (locationLabel.isNotEmpty) locationLabel,
                                job.jobTypeDisplay.isNotEmpty
                                    ? job.jobTypeDisplay
                                    : job.jobType,
                              ].where((s) => s.isNotEmpty).join(' \u2022 '),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          'Urgent',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: AppTypography.wBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
