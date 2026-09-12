import 'package:flutter/material.dart';

import '../radius/app_radius.dart';
import '../shadows/app_shadows.dart';
import '../spacing/app_spacing.dart';

/// Standard surface container used across cards, list items and detail blocks.
///
/// Defaults come from the central [CardTheme]; pass [padding], [onTap] or
/// [color] to customize per use.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final bool hasShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor ?? theme.colorScheme.outlineVariant),
        boxShadow: hasShadow ? [AppShadows.cardShadow] : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderLg,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}
