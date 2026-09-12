import 'package:flutter/material.dart';

import '../typography/app_typography.dart';

/// Typed dropdown input built on [DropdownButtonFormField].
///
/// Use [items] with `label` / `value`, or [builder] for a fully custom item
/// widget. Styling comes from the central `InputDecorationTheme`.
class AppDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? initialValue;
  final String? label;
  final String? hint;
  final String? error;
  final bool isDense;
  final bool isExpanded;
  final ValueChanged<T?>? onChanged;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final String Function(T item)? labelBuilder;
  final Widget? suffixIcon;

  const AppDropdown({
    super.key,
    required this.items,
    this.initialValue,
    this.label,
    this.hint,
    this.error,
    this.isDense = true,
    this.isExpanded = true,
    this.onChanged,
    this.itemBuilder,
    this.labelBuilder,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    String displayLabel(T item) =>
        labelBuilder?.call(item) ?? item.toString();

    return DropdownButtonFormField<T>(
      key: key,
      initialValue:
          items.isNotEmpty && items.contains(initialValue) ? initialValue : null,
      isDense: isDense,
      isExpanded: isExpanded,
      style: AppTypography.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
        suffixIcon: suffixIcon,
      ),
      icon: Icon(Icons.arrow_drop_down_rounded),
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item,
            child: itemBuilder?.call(context, item) ??
                Text(
                  displayLabel(item),
                  style: AppTypography.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
