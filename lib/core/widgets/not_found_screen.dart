import 'package:flutter/material.dart';

import '../../design_system/colors/app_colors.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_typography.dart';

/// Fallback screen for unmatched routes.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Page not found', style: AppTypography.headingMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'The page you are looking for does not exist.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
