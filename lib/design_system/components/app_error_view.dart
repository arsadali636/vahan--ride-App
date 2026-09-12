import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Standard error state with an optional retry action.
class AppErrorView extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData icon;
  final bool fullScreen;

  const AppErrorView({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.icon = Icons.error_outline_rounded,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: AppColors.error),
        const SizedBox(height: AppSpacing.md),
        Text(
          title!,
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
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(retryLabel!),
          ),
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
