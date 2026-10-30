import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Semantic status tone. Maps to central token colors.
enum AppStatusTone { success, warning, error, info, neutral }

extension AppStatusToneColor on AppStatusTone {
  Color get color => switch (this) {
    AppStatusTone.success => AppColors.success,
    AppStatusTone.warning => AppColors.warning,
    AppStatusTone.error => AppColors.error,
    AppStatusTone.info => AppColors.secondary,
    AppStatusTone.neutral => AppColors.textSecondary,
  };
}

/// Small rounded status pill with an optional leading dot / icon.
///
/// Use for application status (ProfileViewed, Shortlisted, Interview, Offered,
/// Hired, Rejected) and other statuses.
class StatusChip extends StatelessWidget {
  final String label;
  final AppStatusTone tone;
  final IconData? icon;
  final bool showDot;

  const StatusChip({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.icon,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = tone.color;
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
          if (showDot && icon == null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
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
