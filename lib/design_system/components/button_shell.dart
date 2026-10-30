import 'package:flutter/material.dart';

import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Button size presets shared by [PrimaryButton], [SecondaryButton] and
/// [OutlineButton].
enum AppButtonSize { small, medium, large }

/// Resolved visual metrics for a given [AppButtonSize].
class AppButtonStyle {
  const AppButtonStyle._({
    required this.height,
    required this.padding,
    required this.textStyle,
  });

  final double height;
  final EdgeInsets padding;
  final TextStyle textStyle;

  static AppButtonStyle of(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return AppButtonStyle._(
          height: 40,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          textStyle: AppTypography.labelMedium,
        );
      case AppButtonSize.medium:
        return AppButtonStyle._(
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.labelLarge,
        );
      case AppButtonSize.large:
        return AppButtonStyle._(
          height: 56,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          textStyle: AppTypography.titleSmall,
        );
    }
  }

  static final BorderRadius borderRadius = AppRadius.borderMd;
}

/// Shared visual builder for the three button variants.
class AppButtonShell {
  const AppButtonShell._();

  static Widget build({
    required Widget child,
    required VoidCallback? onPressed,
    required AppButtonSize size,
    required bool fullWidth,
  }) {
    final style = AppButtonStyle.of(size);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: fullWidth ? double.infinity : style.height,
        minHeight: style.height,
      ),
      child: child,
    );
  }

  static Widget label({
    required BuildContext context,
    required String label,
    IconData? icon,
    required TextStyle textStyle,
  }) {
    final iconWidget = icon == null
        ? null
        : Icon(
            icon,
            size: textStyle.fontSize != null ? textStyle.fontSize! + 2 : 18,
          );
    if (iconWidget == null) {
      return Text(
        label,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static Widget loadingIndicator({
    required BuildContext context,
    required Color color,
    required AppButtonSize size,
  }) {
    final style = AppButtonStyle.of(size);
    return SizedBox(
      height: (style.textStyle.fontSize ?? 14) - 2,
      width: (style.textStyle.fontSize ?? 14) - 2,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}
