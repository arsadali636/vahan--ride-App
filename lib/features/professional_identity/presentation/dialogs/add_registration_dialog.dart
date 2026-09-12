import 'package:flutter/material.dart';

import '../../../../design_system/components/app_dialog.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../domain/entities/doctor_registration_draft.dart';

/// Dialog collecting a new registration. Returns a
/// [DoctorRegistrationDraft] on save.
class AddRegistrationDialog extends StatefulWidget {
  const AddRegistrationDialog({super.key});

  @override
  State<AddRegistrationDialog> createState() => _AddRegistrationDialogState();
}

class _AddRegistrationDialogState extends State<AddRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _councilId = TextEditingController();
  final _registrationNumber = TextEditingController();
  final _registrationYear = TextEditingController();
  bool _isPrimary = false;

  @override
  void dispose() {
    _councilId.dispose();
    _registrationNumber.dispose();
    _registrationYear.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final year = int.tryParse(value.trim());
    if (year == null || year < 1900 || year > 2100) {
      return 'Enter a valid year';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      DoctorRegistrationDraft(
        councilId: _councilId.text.trim(),
        registrationNumber: _registrationNumber.text.trim(),
        registrationYear: int.parse(_registrationYear.text.trim()),
        isPrimary: _isPrimary,
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
            label: 'Council ID *',
            hint: 'e.g. Medical Council of India',
            controller: _councilId,
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Registration number *',
            controller: _registrationNumber,
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Registration year *',
            controller: _registrationYear,
            keyboardType: TextInputType.number,
            validator: _validateYear,
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            value: _isPrimary,
            onChanged: (value) => setState(() => _isPrimary = value),
            title: const Text(
              'Primary registration',
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
              PrimaryButton(
                label: 'Save',
                onPressed: _submit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows the dialog and resolves the [DoctorRegistrationDraft] (or null if
/// dismissed).
Future<DoctorRegistrationDraft?> showAddRegistrationDialog(
  BuildContext context,
) {
  return AppDialog.show<DoctorRegistrationDraft>(
    context: context,
    title: 'Add registration',
    icon: Icons.badge_outlined,
    content: const AddRegistrationDialog(),
  );
}
