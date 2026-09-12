import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../design_system/components/app_empty_view.dart';
import '../../../../design_system/components/app_loader.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../domain/entities/doctor_profile_draft.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../bloc/doctor_profile_state.dart';
import '../widgets/profile_form_fields.dart';

/// Edit flow for the caller's professional profile.
///
/// Loads the current profile and pre-fills the form; saving dispatches a
/// partial update and pops back on success.
class EditProfilePage extends StatelessWidget {
  final DoctorProfileBloc? bloc;

  const EditProfilePage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DoctorProfileBloc>(
      create: (_) => bloc ?? DependencyInjection.get<DoctorProfileBloc>(),
      child: const _EditProfileBody(),
    );
  }
}

class _EditProfileBody extends StatefulWidget {
  const _EditProfileBody();

  @override
  State<_EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<_EditProfileBody> {
  final _formKey = GlobalKey<FormState>();
  DoctorProfileDraft? _draft;

  @override
  void initState() {
    super.initState();
    context.read<DoctorProfileBloc>().add(const DoctorProfileLoadRequested());
  }

  void _submit() {
    final draft = _draft;
    if (draft == null) return;
    if (!_formKey.currentState!.validate()) return;
    context.read<DoctorProfileBloc>().add(DoctorProfileUpdateRequested(draft));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorProfileBloc, DoctorProfileState>(
      listener: (context, state) {
        if (state.status == DoctorProfileStatus.success &&
            state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
          context.pop();
        } else if (state.status == DoctorProfileStatus.failure &&
            state.failure != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.failure!.message)),
            );
        }
      },
      builder: (context, state) {
        final formReady = state.hasProfile;

        return Scaffold(
          appBar: AppBar(title: const Text('Edit profile')),
          body: _buildBody(context, state),
          bottomNavigationBar: formReady
              ? SafeArea(
                  minimum: const EdgeInsets.all(AppSpacing.lg),
                  child: PrimaryButton(
                    label: 'Save changes',
                    isLoading: state.status == DoctorProfileStatus.updating,
                    onPressed: _submit,
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DoctorProfileState state) {
    if (state.status == DoctorProfileStatus.initial ||
        state.status == DoctorProfileStatus.loading) {
      return const AppLoader(label: 'Loading profile…');
    }
    if (!state.hasProfile) {
      return AppEmptyView(
        title: 'No profile to edit yet.',
        message:
            'Create your professional profile first, then come back to edit it.',
        icon: Icons.badge_outlined,
        action: PrimaryButton(
          label: 'Create profile',
          onPressed: () => context.go(AppRouter.completeProfileRoute),
        ),
      );
    }

    _draft ??= DoctorProfileDraft(
      firstName: state.profile!.firstName,
      lastName: state.profile!.lastName,
      headline: state.profile!.headline,
      about: state.profile!.about,
      primarySpecializationId: state.profile!.primarySpecializationId,
      clinicalInterests: state.profile!.clinicalInterests,
      location: state.profile!.professionalLocation,
      experienceYears: state.profile!.experienceYears,
      openToOpportunities: state.profile!.openToOpportunities,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.lg,
        ),
        child: ProfileFormFields(
          formKey: _formKey,
          initial: _draft!,
          onChanged: (value) => _draft = value,
        ),
      ),
    );
  }
}
