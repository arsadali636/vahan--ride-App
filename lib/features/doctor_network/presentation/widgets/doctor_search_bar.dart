import 'package:flutter/material.dart';

import '../../../../design_system/components/search_field.dart';
import '../../../../design_system/spacing/app_spacing.dart';

/// Top search input for doctor discovery.
///
/// Reuses the central [SearchField]; [onChanged] is expected to feed the
/// debounced `DoctorSearchQueryChanged` BLoC event.
class DoctorSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const DoctorSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: SearchField(
        controller: controller,
        hint: 'Search doctors by name, specialty or location',
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
