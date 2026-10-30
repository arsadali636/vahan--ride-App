import 'package:flutter/material.dart';

import '../../../../core/utils/url_utils.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/suggested_doctor.dart';

/// Renders suggested doctors returned by `GET /api/v1/feed/home/`.
class SuggestedDoctorsSection extends StatelessWidget {
  final List<SuggestedDoctor> doctors;
  final ValueChanged<SuggestedDoctor>? onConnectPressed;

  const SuggestedDoctorsSection({
    super.key,
    required this.doctors,
    this.onConnectPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended Doctors',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.wBold,
                  ),
                ),
                Text(
                  'See all',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: AppTypography.wSemiBold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 200,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              scrollDirection: Axis.horizontal,
              itemCount: doctors.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                return _SuggestedDoctorCard(
                  doctor: doctors[index],
                  onConnectPressed: onConnectPressed,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedDoctorCard extends StatelessWidget {
  final SuggestedDoctor doctor;
  final ValueChanged<SuggestedDoctor>? onConnectPressed;

  const _SuggestedDoctorCard({required this.doctor, this.onConnectPressed});

  @override
  Widget build(BuildContext context) {
    final locationCity =
        doctor.location['city'] as String? ??
        doctor.location.values.whereType<String>().firstOrNull ??
        '';

    final isVerified = doctor.verificationStatus.toLowerCase() == 'verified';

    final resolvedPhoto = UrlUtils.resolveUrl(doctor.photo);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DoctorAvatar(
            photoUrl: resolvedPhoto,
            firstName: doctor.fullName.isNotEmpty
                ? doctor.fullName.split(' ').first
                : (doctor.initials.isNotEmpty ? doctor.initials : 'Dr.'),
            lastName: doctor.fullName.contains(' ')
                ? doctor.fullName.split(' ').skip(1).join(' ')
                : null,
            size: 52,
            verified: isVerified,
          ),
          Column(
            children: [
              Text(
                doctor.fullName,
                style: AppTypography.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (doctor.headline.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  doctor.headline,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
              if (doctor.experienceYears > 0 || locationCity.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  [
                    if (doctor.experienceYears > 0)
                      '${doctor.experienceYears} yrs exp',
                    if (locationCity.isNotEmpty) locationCity,
                  ].join(' \u2022 '),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textDisabled,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton(
              onPressed: () => onConnectPressed?.call(doctor),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderCircular,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'Connect',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppTypography.wSemiBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
