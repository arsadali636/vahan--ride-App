import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Verification indicator shown next to verified doctors and verified
/// workplace accounts.
class VerificationBadge extends StatelessWidget {
  final String? label;
  final double size;

  const VerificationBadge({super.key, this.label, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.verified_rounded,
        size: size,
        color: AppColors.textOnPrimary,
      ),
    );

    if (label == null) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        SizedBox(width: AppSpacing.xs),
        Text(
          label!,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
