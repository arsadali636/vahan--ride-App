import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_empty_view.dart';
import '../../../../design_system/components/app_error_view.dart';
import '../../../../design_system/components/app_loader.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../bloc/doctor_network_bloc.dart';
import '../bloc/doctor_network_event.dart';
import '../bloc/doctor_network_state.dart';
import '../widgets/doctor_network_actions.dart';
import '../widgets/doctor_profile_header.dart';

/// Public view of another doctor's professional profile.
///
/// Reads the backend's public profile response only — private fields (phone,
/// personal email, compensation, availability) are never shown, even if a
/// locally cached object contained them.
class DoctorPublicProfilePage extends StatelessWidget {
  final String doctorId;

  /// Optional override for tests; defaults to the DI-provided instance.
  final DoctorNetworkBloc? bloc;

  const DoctorPublicProfilePage({super.key, required this.doctorId, this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DoctorNetworkBloc>(
      create: (_) => bloc ?? DependencyInjection.get<DoctorNetworkBloc>(),
      child: _DoctorPublicProfileBody(doctorId: doctorId),
    );
  }
}

class _DoctorPublicProfileBody extends StatefulWidget {
  final String doctorId;

  const _DoctorPublicProfileBody({required this.doctorId});

  @override
  State<_DoctorPublicProfileBody> createState() =>
      _DoctorPublicProfileBodyState();
}

class _DoctorPublicProfileBodyState extends State<_DoctorPublicProfileBody> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorNetworkBloc>().add(
      DoctorProfileRequested(widget.doctorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor profile')),
      body: BlocConsumer<DoctorNetworkBloc, DoctorNetworkState>(
        listener: (context, state) {
          if (state.profileStatus == DoctorNetworkProfileStatus.failure &&
              state.profileError != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.profileError!.message)),
              );
          }
        },
        builder: (context, state) {
          switch (state.profileStatus) {
            case DoctorNetworkProfileStatus.initial:
            case DoctorNetworkProfileStatus.loading:
              return const AppLoader(label: 'Loading profile…');
            case DoctorNetworkProfileStatus.failure:
              return AppErrorView(
                title: 'Could not load this doctor',
                message: state.profileError?.message,
                onRetry: () => context.read<DoctorNetworkBloc>().add(
                  DoctorProfileRequested(widget.doctorId),
                ),
              );
            case DoctorNetworkProfileStatus.loaded:
              final profile = state.profile;
              if (profile == null) {
                return const AppEmptyView(
                  title: 'Profile unavailable',
                  icon: Icons.person_off_outlined,
                );
              }
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: DoctorProfileHeader(profile: profile),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: const DoctorNetworkActions(),
                  ),
                  if (profile.about != null && profile.about!.isNotEmpty)
                    _SectionCard(title: 'About', child: Text(profile.about!)),
                  if (profile.primarySpecializationId != null &&
                      profile.primarySpecializationId!.isNotEmpty)
                    _SectionCard(
                      title: 'Specialization',
                      child: Text(profile.primarySpecializationId!),
                    ),
                  if (profile.experienceYears > 0)
                    _SectionCard(
                      title: 'Experience',
                      child: Text(
                        '${_formatYears(profile.experienceYears)} years',
                      ),
                    ),
                  if (profile.clinicalInterests.isNotEmpty)
                    _SectionCard(
                      title: 'Clinical interests',
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final interest in profile.clinicalInterests)
                            Chip(label: Text(interest)),
                        ],
                      ),
                    ),
                ],
              );
          }
        },
      ),
    );
  }

  static String _formatYears(double years) {
    return years == years.roundToDouble() ? '${years.toInt()}' : '$years';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}
