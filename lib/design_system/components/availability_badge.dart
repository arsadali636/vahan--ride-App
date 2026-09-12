import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Availability badge (green) used on the doctor profile to show they are
/// accepting new work.
class AvailabilityBadge extends StatelessWidget {
  final String label;
  final bool isAvailable;

  const AvailabilityBadge({
    super.key,
    this.label = 'Available',
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppColors.workforce : AppColors.textDisabled;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? color.withValues(alpha: 0.16)
        : color.withValues(alpha: 0.10);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.borderCircular,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
