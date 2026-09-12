import 'package:flutter/material.dart';

import '../../../../design_system/components/app_dialog.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../domain/entities/doctor_qualification_draft.dart';

/// Dialog collecting a new qualification. Returns a
/// [DoctorQualificationDraft] on save.
class AddQualificationDialog extends StatefulWidget {
  const AddQualificationDialog({super.key});

  @override
  State<AddQualificationDialog> createState() => _AddQualificationDialogState();
}

class _AddQualificationDialogState extends State<AddQualificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _degree = TextEditingController();
  final _institution = TextEditingController();
  final _year = TextEditingController();
  final _specialization = TextEditingController();

  @override
  void dispose() {
    _degree.dispose();
    _institution.dispose();
    _year.dispose();
    _specialization.dispose();
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
      DoctorQualificationDraft(
        degree: _degree.text.trim(),
        institution: _institution.text.trim(),
        year: int.parse(_year.text.trim()),
        specialization: _specialization.text.trim().isEmpty
            ? null
            : _specialization.text.trim(),
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
            label: 'Degree *',
            hint: 'e.g. MBBS, MD',
            controller: _degree,
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Institution *',
            hint: 'e.g. Grant Medical College',
            controller: _institution,
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Year *',
            controller: _year,
            keyboardType: TextInputType.number,
            validator: _validateYear,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Specialization',
            hint: 'e.g. Cardiology',
            controller: _specialization,
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

/// Shows the dialog and resolves the [DoctorQualificationDraft] (or null if
/// dismissed).
Future<DoctorQualificationDraft?> showAddQualificationDialog(
  BuildContext context,
) {
  return AppDialog.show<DoctorQualificationDraft>(
    context: context,
    title: 'Add qualification',
    icon: Icons.school_outlined,
    content: const AddQualificationDialog(),
  );
}
