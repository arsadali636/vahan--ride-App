import 'package:flutter/material.dart';

import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/components/status_chip.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/public_doctor_profile.dart';
import '../../../../features/professional_identity/presentation/widgets/verification_status_chip.dart';

/// Header for a doctor's public profile: avatar, name, headline, verification
/// and location. Renders only fields the backend actually returns.
class DoctorProfileHeader extends StatelessWidget {
  final PublicDoctorProfile profile;

  const DoctorProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DoctorAvatar(
          firstName: profile.firstName,
          lastName: profile.lastName,
          size: 72,
          verified: profile.isVerified,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                style: AppTypography.headingMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              VerificationStatusChip(status: profile.verificationStatus),
              if (profile.headline != null &&
                  profile.headline!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.headline!,
                  style: AppTypography.bodyMedium,
                ),
              ],
              if (profile.locationLabel != null &&
                  profile.locationLabel!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Flexible(
                      child: Text(
                        profile.locationLabel!,
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
              if (profile.openToOpportunities) ...[
                const SizedBox(height: AppSpacing.xs),
                const StatusChip(
                  label: 'Open to opportunities',
                  tone: AppStatusTone.success,
                  icon: Icons.waving_hand_outlined,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
