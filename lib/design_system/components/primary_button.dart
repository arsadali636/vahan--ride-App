import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import 'button_shell.dart';

/// Primary call-to-action button (filled with the brand color).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonSize size;
  final bool fullWidth;
  final IconData? icon;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.size = AppButtonSize.medium,
    this.fullWidth = false,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppButtonStyle.of(size);
    final bg = backgroundColor ?? Theme.of(context).colorScheme.primary;

    final button = ElevatedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: bg.withValues(alpha: 0.4),
        disabledForegroundColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
        elevation: 0,
        padding: style.padding,
        shape: RoundedRectangleBorder(
          borderRadius: AppButtonStyle.borderRadius,
        ),
        textStyle: style.textStyle.copyWith(color: AppColors.textOnPrimary),
      ),
      child: isLoading
          ? AppButtonShell.loadingIndicator(
              context: context,
              color: AppColors.textOnPrimary,
              size: size,
            )
          : AppButtonShell.label(
              context: context,
              label: label,
              icon: icon,
              textStyle: style.textStyle.copyWith(color: AppColors.textOnPrimary),
            ),
    );

    return AppButtonShell.build(
      child: button,
      onPressed: onPressed,
      size: size,
      fullWidth: fullWidth,
    );
  }
}
