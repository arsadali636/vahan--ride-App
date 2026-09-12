import 'package:flutter/material.dart';

import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/doctor_profile.dart';
import 'verification_status_chip.dart';

/// Display header for a doctor profile: avatar, display name, verification
/// chip and headline on a soft tinted hero surface.
class ProfileHeader extends StatelessWidget {
  final DoctorProfile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  primary.withValues(alpha: 0.28),
                  AppColors.surfaceDark,
                ]
              : [
                  primary.withValues(alpha: 0.10),
                  AppColors.surface,
                ],
        ),
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoctorAvatar(
            firstName: profile.firstName,
            lastName: profile.lastName,
            size: 84,
            verified: profile.isVerified,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: AppTypography.headingMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                VerificationStatusChip(status: profile.verificationStatus),
                if (profile.headline != null && profile.headline!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    profile.headline!,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
