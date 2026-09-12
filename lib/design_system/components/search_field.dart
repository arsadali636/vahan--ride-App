import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

/// Search input with leading search icon and an optional clear button.
class SearchField extends StatelessWidget {
  final String? hint;
  final String? error;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  const SearchField({
    super.key,
    this.hint = 'Search',
    this.error,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    final showClear = ValueNotifier<bool>(ctrl?.text.isNotEmpty ?? false);

    return ValueListenableBuilder<bool>(
      valueListenable: showClear,
      builder: (context, hasText, _) {
        return TextField(
          controller: ctrl,
          focusNode: focusNode,
          enabled: enabled,
          autofocus: autofocus,
          textInputAction: TextInputAction.search,
          style: AppTypography.bodyLarge,
          onChanged: (value) {
            showClear.value = value.isNotEmpty;
            onChanged?.call(value);
          },
          onSubmitted: onSubmitted,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded),
                    tooltip: 'Clear',
                    color: AppColors.textSecondary,
                    onPressed: () {
                      ctrl?.clear();
                      showClear.value = false;
                      onChanged?.call('');
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}
