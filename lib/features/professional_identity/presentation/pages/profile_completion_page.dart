import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/doctor_profile_draft.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../bloc/doctor_profile_state.dart';
import '../widgets/profile_form_fields.dart';

/// First-time profile creation flow, shown when the account has no
/// professional profile yet.
///
/// On success the backend flag is flipped to `profile_created: true` (through
/// [DoctorProfileBloc]) and the user is routed to the profile screen.
class ProfileCompletionPage extends StatelessWidget {
  final DoctorProfileBloc? bloc;

  const ProfileCompletionPage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DoctorProfileBloc>(
      create: (_) => bloc ?? DependencyInjection.get<DoctorProfileBloc>(),
      child: const _ProfileCompletionBody(),
    );
  }
}

class _ProfileCompletionBody extends StatefulWidget {
  const _ProfileCompletionBody();

  @override
  State<_ProfileCompletionBody> createState() => _ProfileCompletionBodyState();
}

class _ProfileCompletionBodyState extends State<_ProfileCompletionBody> {
  final _formKey = GlobalKey<FormState>();
  DoctorProfileDraft _draft = const DoctorProfileDraft(
    firstName: '',
    lastName: '',
  );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<DoctorProfileBloc>().add(DoctorProfileCreateRequested(_draft));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorProfileBloc, DoctorProfileState>(
      listener: (context, state) {
        if (state.status == DoctorProfileStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Profile created')),
            );
          context.go(AppRouter.profileRoute);
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
        return Scaffold(
          appBar: AppBar(title: const Text('Complete your profile')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'Tell hospitals who you are and how to find you.',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ProfileFormFields(
                    formKey: _formKey,
                    onChanged: (draft) => _draft = draft,
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(AppSpacing.lg),
            child: PrimaryButton(
              label: 'Create profile',
              isLoading: state.status == DoctorProfileStatus.creating,
              onPressed: _submit,
            ),
          ),
        );
      },
    );
  }
}
