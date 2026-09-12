import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/components/app_bottom_sheet.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../bloc/doctor_network_state.dart';

/// Result of the filter sheet.
class DoctorSearchFilterResult {
  final DoctorNetworkFilters filters;
  final bool clearedAll;

  const DoctorSearchFilterResult(this.filters, {this.clearedAll = false});
}

/// Filter entry point for doctor discovery.
///
/// Shows the active-filter count on the trigger button and opens a bottom
/// sheet (via the central [AppBottomSheet]) with the backend-supported
/// filters: specialty, city, minimum experience and open-to-opportunities.
class DoctorSearchFilterBar extends StatelessWidget {
  final DoctorNetworkFilters filters;
  final ValueChanged<DoctorSearchFilterResult> onResult;

  const DoctorSearchFilterBar({
    super.key,
    required this.filters,
    required this.onResult,
  });

  int get _activeCount => [
        if (filters.specialty != null && filters.specialty!.isNotEmpty) 1,
        if (filters.city != null && filters.city!.isNotEmpty) 1,
        if (filters.experienceMin != null) 1,
        if (filters.openToOpportunities != null) 1,
      ].length;

  Future<void> _open(BuildContext context) async {
    final result = await AppBottomSheet.show<DoctorSearchFilterResult>(
      context: context,
      title: 'Filters',
      isScrollControlled: true,
      child: _DoctorSearchFiltersSheet(initial: filters),
    );
    if (result != null) onResult(result);
  }

  @override
  Widget build(BuildContext context) {
    final count = _activeCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          OutlineButton(
            label: count == 0 ? 'Filters' : 'Filters · $count',
            icon: Icons.tune_rounded,
            onPressed: () => _open(context),
          ),
        ],
      ),
    );
  }
}

class _DoctorSearchFiltersSheet extends StatefulWidget {
  final DoctorNetworkFilters initial;

  const _DoctorSearchFiltersSheet({required this.initial});

  @override
  State<_DoctorSearchFiltersSheet> createState() =>
      _DoctorSearchFiltersSheetState();
}

class _DoctorSearchFiltersSheetState extends State<_DoctorSearchFiltersSheet> {
  late final TextEditingController _specialty;
  late final TextEditingController _city;
  late final TextEditingController _experience;
  late bool _openToOpportunities;

  @override
  void initState() {
    super.initState();
    _specialty = TextEditingController(text: widget.initial.specialty ?? '');
    _city = TextEditingController(text: widget.initial.city ?? '');
    _experience = TextEditingController(
      text: widget.initial.experienceMin?.toString() ?? '',
    );
    _openToOpportunities = widget.initial.openToOpportunities ?? false;
  }

  @override
  void dispose() {
    _specialty.dispose();
    _city.dispose();
    _experience.dispose();
    super.dispose();
  }

  DoctorNetworkFilters get _draft {
    return DoctorNetworkFilters(
      specialty: _specialty.text.trim().isEmpty ? null : _specialty.text.trim(),
      city: _city.text.trim().isEmpty ? null : _city.text.trim(),
      experienceMin: double.tryParse(_experience.text.trim()),
      openToOpportunities: _openToOpportunities ? true : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _specialty,
          label: 'Specialty',
          hint: 'e.g. Cardiology',
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _city,
          label: 'City',
          hint: 'e.g. Mumbai',
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _experience,
          label: 'Minimum experience (years)',
          hint: 'e.g. 5',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Open to opportunities',
            style: AppTypography.bodyLarge,
          ),
          subtitle: const Text('Only show doctors actively seeking roles'),
          value: _openToOpportunities,
          onChanged: (value) =>
              setState(() => _openToOpportunities = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlineButton(
                label: 'Clear all',
                color: AppColors.textSecondary,
                onPressed: () =>
                    Navigator.of(context).pop(const DoctorSearchFilterResult(
                  DoctorNetworkFilters(),
                  clearedAll: true,
                )),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: PrimaryButton(
                label: 'Apply filters',
                onPressed: () =>
                    Navigator.of(context).pop(DoctorSearchFilterResult(_draft)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
