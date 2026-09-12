import 'package:flutter/material.dart';

import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/components/status_chip.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/doctor_search_result.dart';

/// One doctor entry in the discovery results list.
///
/// Renders only fields the backend actually supplies — nothing is fabricated.
/// Tapping opens the doctor's public profile.
class DoctorSearchResultCard extends StatelessWidget {
  final DoctorSearchResult result;
  final VoidCallback onTap;

  const DoctorSearchResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (result.primarySpecializationId != null &&
          result.primarySpecializationId!.isNotEmpty)
        result.primarySpecializationId!,
      if (result.locationLabel != null && result.locationLabel!.isNotEmpty)
        result.locationLabel!,
    ];

    return AppCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoctorAvatar(
            firstName: result.firstName,
            lastName: result.lastName,
            size: 48,
            verified: result.isVerified,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.displayName,
                  style: AppTypography.titleSmall,
                ),
                if (result.headline != null &&
                    result.headline!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    result.headline!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (subtitleParts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitleParts.join(' • '),
                    style: AppTypography.bodySmall,
                  ),
                ],
                if (result.experienceYears > 0 ||
                    result.openToOpportunities) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (result.experienceYears > 0)
                        _ExperienceLabel(years: result.experienceYears),
                      if (result.experienceYears > 0 &&
                          result.openToOpportunities)
                        const SizedBox(width: AppSpacing.sm),
                      if (result.openToOpportunities)
                        const StatusChip(
                          label: 'Open to opportunities',
                          tone: AppStatusTone.success,
                          icon: Icons.waving_hand_outlined,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceLabel extends StatelessWidget {
  final double years;

  const _ExperienceLabel({required this.years});

  @override
  Widget build(BuildContext context) {
    final yearsLabel = years == years.roundToDouble()
        ? '${years.toInt()}'
        : '$years';
    return Text(
      '$yearsLabel yrs experience',
      style: AppTypography.labelSmall.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
}
