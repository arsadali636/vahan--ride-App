import 'package:flutter/material.dart';

import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Modal bottom sheet helper with consistent theming.
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = false,
    bool isDismissible = true,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      showDragHandle: true,
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight)
          : null,
      builder: (context) {
        final content = SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: child,
          ),
        );
        if (title == null) return content;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                title,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            content,
          ],
        );
      },
    );
  }
}
