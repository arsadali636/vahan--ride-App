import 'package:flutter/material.dart';

import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/doctor_profile_draft.dart';
import '../../domain/entities/location.dart';
import 'clinical_interests_editor.dart';
import 'profile_section_card.dart';

/// Renders every writable profile field and reports the edited snapshot as a
/// [DoctorProfileDraft] through [onChanged].
///
/// Shared by the profile completion and edit flows. The owning page owns the
/// [formKey] so it can run validation before submitting.
class ProfileFormFields extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final DoctorProfileDraft? initial;
  final ValueChanged<DoctorProfileDraft> onChanged;

  const ProfileFormFields({
    super.key,
    required this.formKey,
    this.initial,
    required this.onChanged,
  });

  @override
  State<ProfileFormFields> createState() => _ProfileFormFieldsState();
}

class _ProfileFormFieldsState extends State<ProfileFormFields> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _headline;
  late final TextEditingController _about;
  late final TextEditingController _specializationId;
  late final TextEditingController _experienceYears;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;

  late List<String> _interests;
  late bool _openToOpportunities;

  DoctorProfileDraft get _initial =>
      widget.initial ?? const DoctorProfileDraft(firstName: '', lastName: '');

  @override
  void initState() {
    super.initState();
    final initial = _initial;
    _firstName = TextEditingController(text: initial.firstName);
    _lastName = TextEditingController(text: initial.lastName);
    _headline = TextEditingController(text: initial.headline ?? '');
    _about = TextEditingController(text: initial.about ?? '');
    _specializationId = TextEditingController(
      text: initial.primarySpecializationId ?? '',
    );
    _experienceYears = TextEditingController(
      text: initial.experienceYears?.toString() ?? '',
    );
    _address = TextEditingController(text: initial.location?.address ?? '');
    _city = TextEditingController(text: initial.location?.city ?? '');
    _state = TextEditingController(text: initial.location?.state ?? '');
    _pincode = TextEditingController(text: initial.location?.pincode ?? '');
    _interests = List.of(initial.clinicalInterests);
    _openToOpportunities = initial.openToOpportunities ?? false;

    _firstName.addListener(_emit);
    _lastName.addListener(_emit);
    _headline.addListener(_emit);
    _about.addListener(_emit);
    _specializationId.addListener(_emit);
    _experienceYears.addListener(_emit);
    _address.addListener(_emit);
    _city.addListener(_emit);
    _state.addListener(_emit);
    _pincode.addListener(_emit);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _headline.dispose();
    _about.dispose();
    _specializationId.dispose();
    _experienceYears.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    super.dispose();
  }

  void _emit() {
    final city = _city.text.trim();
    final state = _state.text.trim();
    widget.onChanged(
      DoctorProfileDraft(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        headline: _headline.text.trim().isEmpty ? null : _headline.text.trim(),
        about: _about.text.trim().isEmpty ? null : _about.text.trim(),
        primarySpecializationId: _specializationId.text.trim().isEmpty
            ? null
            : _specializationId.text.trim(),
        clinicalInterests: _interests,
        location: city.isNotEmpty && state.isNotEmpty
            ? Location(
                address: _address.text.trim().isEmpty
                    ? null
                    : _address.text.trim(),
                city: city,
                state: state,
                pincode: _pincode.text.trim().isEmpty
                    ? null
                    : _pincode.text.trim(),
              )
            : null,
        experienceYears: double.tryParse(_experienceYears.text.trim()),
        openToOpportunities: _openToOpportunities,
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _validateYears(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) return 'Enter a valid number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileSectionCard(
            icon: Icons.person_outline,
            title: 'Basic details',
            child: Column(
              children: [
                AppTextField(
                  label: 'First name *',
                  controller: _firstName,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateName,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Last name *',
                  controller: _lastName,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateName,
                ),
              ],
            ),
          ),
          ProfileSectionCard(
            icon: Icons.medical_services_outlined,
            title: 'Professional details',
            child: Column(
              children: [
                AppTextField(
                  label: 'Headline',
                  hint: 'e.g. Senior Cardiologist',
                  controller: _headline,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'About',
                  controller: _about,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Primary specialization (ID)',
                  helper: 'As provided by the backend specialization list.',
                  controller: _specializationId,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Years of experience',
                  controller: _experienceYears,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validateYears,
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  value: _openToOpportunities,
                  onChanged: (value) {
                    setState(() => _openToOpportunities = value);
                    _emit();
                  },
                  title: const Text(
                    'Open to opportunities',
                    style: AppTypography.bodyLarge,
                  ),
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.primary,
                ),
              ],
            ),
          ),
          ProfileSectionCard(
            icon: Icons.location_on_outlined,
            title: 'Professional location',
            child: Column(
              children: [
                AppTextField(
                  label: 'City *',
                  controller: _city,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'State *',
                  controller: _state,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Pincode',
                  controller: _pincode,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Address',
                  controller: _address,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          ProfileSectionCard(
            icon: Icons.favorite_outline,
            title: 'Clinical interests',
            child: ClinicalInterestsEditor(
              initial: _interests,
              onChanged: (interests) {
                _interests = interests;
                _emit();
              },
            ),
          ),
        ],
      ),
    );
  }
}
