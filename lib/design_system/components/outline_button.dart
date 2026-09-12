import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import 'button_shell.dart';

/// Outline button (primary border/text on a transparent fill).
class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonSize size;
  final bool fullWidth;
  final IconData? icon;
  final Color? color;

  const OutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.size = AppButtonSize.medium,
    this.fullWidth = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppButtonStyle.of(size);
    final fg = color ?? Theme.of(context).colorScheme.primary;

    final button = OutlinedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        disabledForegroundColor: AppColors.textDisabled,
        side: BorderSide(color: fg.withValues(alpha: 0.6)),
        backgroundColor: Colors.transparent,
        padding: style.padding,
        shape: RoundedRectangleBorder(
          borderRadius: AppButtonStyle.borderRadius,
        ),
        textStyle: style.textStyle.copyWith(color: fg),
      ),
      child: isLoading
          ? AppButtonShell.loadingIndicator(
              context: context,
              color: fg,
              size: size,
            )
          : AppButtonShell.label(
              context: context,
              label: label,
              icon: icon,
              textStyle: style.textStyle.copyWith(color: fg),
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
