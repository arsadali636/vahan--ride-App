import 'package:flutter/material.dart';

import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';

/// Titled surface for a professional-profile block: leading icon badge, title,
/// optional trailing [action] and the section content below.
///
/// Used by the profile screen and its sub-sections so every block shares the
/// same card anatomy, spacing and icon treatment.
class ProfileSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? action;
  final EdgeInsetsGeometry margin;

  const ProfileSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.action,
    this.margin = const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.xs,
      AppSpacing.md,
      AppSpacing.xs,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AppCard(
      hasShadow: true,
      margin: margin,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(icon, size: 22, color: primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(title, style: AppTypography.titleMedium)),
              ?action,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
