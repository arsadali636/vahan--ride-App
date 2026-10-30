import 'package:flutter/material.dart';

import '../../../../design_system/components/app_dialog.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../domain/entities/doctor_experience_draft.dart';

/// Dialog collecting a new work-experience entry. Returns a
/// [DoctorExperienceDraft] on save.
class AddExperienceDialog extends StatefulWidget {
  const AddExperienceDialog({super.key});

  @override
  State<AddExperienceDialog> createState() => _AddExperienceDialogState();
}

class _AddExperienceDialogState extends State<AddExperienceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _role = TextEditingController();
  final _hospitalName = TextEditingController();
  final _location = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();
  bool _isCurrent = false;

  @override
  void dispose() {
    _role.dispose();
    _hospitalName.dispose();
    _location.dispose();
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final match = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim());
    return match ? null : 'Use YYYY-MM-DD';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      DoctorExperienceDraft(
        role: _role.text.trim(),
        hospitalName: _hospitalName.text.trim(),
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        startDate: _startDate.text.trim().isEmpty
            ? null
            : _startDate.text.trim(),
        endDate: _isCurrent || _endDate.text.trim().isEmpty
            ? null
            : _endDate.text.trim(),
        isCurrent: _isCurrent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Role *',
            hint: 'e.g. Resident Physician',
            controller: _role,
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Hospital / organization *',
            controller: _hospitalName,
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Location',
            hint: 'e.g. Mumbai, Maharashtra',
            controller: _location,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Start date',
            hint: 'YYYY-MM-DD',
            controller: _startDate,
            validator: _validateDate,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'End date',
            hint: 'YYYY-MM-DD (omit if current)',
            controller: _endDate,
            validator: _validateDate,
            enabled: !_isCurrent,
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            value: _isCurrent,
            onChanged: (value) => setState(() => _isCurrent = value),
            title: const Text(
              'I currently work here',
              style: TextStyle(fontSize: 15),
            ),
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlineButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: AppSpacing.sm),
              PrimaryButton(label: 'Save', onPressed: _submit),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows the dialog and resolves the [DoctorExperienceDraft] (or null if
/// dismissed).
Future<DoctorExperienceDraft?> showAddExperienceDialog(BuildContext context) {
  return AppDialog.show<DoctorExperienceDraft>(
    context: context,
    title: 'Add experience',
    icon: Icons.work_outline,
    content: const AddExperienceDialog(),
  );
}
