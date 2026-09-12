import 'package:flutter/material.dart';

import '../../../../design_system/components/status_chip.dart';
import '../../domain/entities/doctor_verification_status.dart';

/// Maps a backend [DoctorVerificationStatus] to a tone-matched [StatusChip].
///
/// Verification is never computed locally — it reflects exactly what the
/// backend reported for the profile.
class VerificationStatusChip extends StatelessWidget {
  final DoctorVerificationStatus status;

  const VerificationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case DoctorVerificationStatus.verified:
        return const StatusChip(
          label: 'Verified doctor',
          tone: AppStatusTone.success,
          icon: Icons.verified_rounded,
        );
      case DoctorVerificationStatus.pending:
        return const StatusChip(
          label: 'Verification pending',
          tone: AppStatusTone.warning,
          icon: Icons.hourglass_top_rounded,
        );
      case DoctorVerificationStatus.rejected:
        return const StatusChip(
          label: 'Verification rejected',
          tone: AppStatusTone.error,
          icon: Icons.gpp_bad_rounded,
        );
      case DoctorVerificationStatus.unverified:
        return const StatusChip(
          label: 'Unverified',
          tone: AppStatusTone.neutral,
          icon: Icons.verified_user_rounded,
        );
    }
  }
}
