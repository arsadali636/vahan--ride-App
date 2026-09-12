import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/dependency_injection.dart';
import '../../../../app/app_router.dart';
import '../../../../design_system/components/app_error_view.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../bloc/doctor_profile_state.dart';
import '../widgets/doctor_profile_view.dart';

/// Read-only view of the caller's doctor professional profile.
///
/// Owns a [DoctorProfileBloc] and lets the user edit the profile, upload a
/// photo and manage qualifications/registrations/experiences.
class DoctorProfilePage extends StatelessWidget {
  /// Optional override for tests; defaults to the DI-provided instance.
  final DoctorProfileBloc? bloc;

  const DoctorProfilePage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DoctorProfileBloc>(
      create: (_) => bloc ?? DependencyInjection.get<DoctorProfileBloc>(),
      child: const _DoctorProfileBody(),
    );
  }
}

class _DoctorProfileBody extends StatefulWidget {
  const _DoctorProfileBody();

  @override
  State<_DoctorProfileBody> createState() => _DoctorProfileBodyState();
}

class _DoctorProfileBodyState extends State<_DoctorProfileBody> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorProfileBloc>().add(const DoctorProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRouter.editProfileRoute),
          ),
        ],
      ),
      body: BlocConsumer<DoctorProfileBloc, DoctorProfileState>(
        listener: (context, state) {
          if (state.status == DoctorProfileStatus.success &&
              state.message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message!)));
          } else if (state.status == DoctorProfileStatus.failure &&
              state.failure != null &&
              state.hasProfile) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.failure!.message)),
              );
          }
        },
        builder: (context, state) {
          if (state.status == DoctorProfileStatus.failure) {
            return AppErrorView(
              title: 'Could not load your profile',
              message: state.failure?.message,
              onRetry: () =>
                  context.read<DoctorProfileBloc>().add(const DoctorProfileLoadRequested()),
            );
          }
          return DoctorProfileView(state: state);
        },
      ),
    );
  }
}
