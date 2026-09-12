import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Standard empty state with an icon, title, optional message and action.
class AppEmptyView extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;
  final bool fullScreen;

  const AppEmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: AppColors.textDisabled),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: AppTypography.titleSmall,
          textAlign: TextAlign.center,
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: AppSpacing.lg),
          action!,
        ],
      ],
    );

    if (!fullScreen) return content;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: content,
      ),
    );
  }
}
