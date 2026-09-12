import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design_system/components/app_empty_view.dart';
import '../../../../design_system/components/app_loader.dart';
import '../../../../design_system/components/status_chip.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/doctor_profile.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../bloc/doctor_profile_state.dart';
import 'experiences_section.dart';
import 'photo_upload_section.dart';
import 'profile_header.dart';
import 'profile_section_card.dart';
import 'qualifications_section.dart';
import 'registrations_section.dart';

/// Renders the loaded doctor profile (or the appropriate loading / empty /
/// completion states).
class DoctorProfileView extends StatelessWidget {
  final DoctorProfileState state;

  const DoctorProfileView({super.key, required this.state});

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<DoctorProfileBloc>();
    final done = Completer<void>();
    final sub = bloc.stream.listen((current) {
      if (current.status != DoctorProfileStatus.refreshing && !done.isCompleted) {
        done.complete();
      }
    });
    bloc.add(const DoctorProfileRefreshRequested());
    await done.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {},
    );
    await sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (state.status == DoctorProfileStatus.initial ||
        state.status == DoctorProfileStatus.loading) {
      return const AppLoader(label: 'Loading profile…');
    }

    if (state.needsCompletion) {
      return AppEmptyView(
        title: 'Complete your profile',
        message:
            'Add your professional details so hospitals can find and verify you.',
        icon: Icons.badge_outlined,
      );
    }

    final profile = state.profile;
    if (profile == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ProfileHeader(profile: profile),
          ),
          const SizedBox(height: AppSpacing.xs),
          PhotoUploadSection(profile: profile),
          if (profile.about != null && profile.about!.isNotEmpty)
            _AboutCard(profile: profile),
          if (profile.primarySpecializationId != null &&
              profile.primarySpecializationId!.isNotEmpty)
            _SpecializationCard(profile: profile),
          if (profile.experienceYears > 0 || profile.openToOpportunities)
            _MetricsCard(profile: profile),
          if (profile.professionalLocation != null)
            _LocationCard(profile: profile),
          if (profile.clinicalInterests.isNotEmpty)
            _InterestsCard(profile: profile),
          QualificationsSection(qualifications: state.qualifications),
          RegistrationsSection(registrations: state.registrations),
          ExperiencesSection(experiences: state.experiences),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final DoctorProfile profile;

  const _AboutCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      icon: Icons.notes_outlined,
      title: 'About',
      child: Text(profile.about!, style: AppTypography.bodyLarge),
    );
  }
}

class _SpecializationCard extends StatelessWidget {
  final DoctorProfile profile;

  const _SpecializationCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      icon: Icons.medical_services_outlined,
      title: 'Specialization',
      child: Text(
        profile.primarySpecializationId!,
        style: AppTypography.bodyLarge,
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  final DoctorProfile profile;

  const _MetricsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final years = profile.experienceYears;
    final yearsLabel = years == years.roundToDouble()
        ? '${years.toInt()}'
        : '$years';

    return ProfileSectionCard(
      icon: Icons.workspace_premium_outlined,
      title: 'Career snapshot',
      child: Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (years > 0)
            _Metric(
              icon: Icons.work_history_outlined,
              value: '$yearsLabel yrs',
              label: 'Experience',
            ),
          if (profile.openToOpportunities)
            const StatusChip(
              label: 'Open to opportunities',
              tone: AppStatusTone.success,
              icon: Icons.waving_hand_outlined,
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.titleMedium),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  final DoctorProfile profile;

  const _LocationCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final location = profile.professionalLocation!;
    final details = [
      if (location.address != null && location.address!.isNotEmpty)
        location.address,
      if (location.pincode != null && location.pincode!.isNotEmpty)
        location.pincode,
    ].join(', ');

    return ProfileSectionCard(
      icon: Icons.location_on_outlined,
      title: 'Location',
      child: Row(
        children: [
          Expanded(
            child: Text(
              details.isNotEmpty ? '$details • ${location.label}' : location.label,
              style: AppTypography.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestsCard extends StatelessWidget {
  final DoctorProfile profile;

  const _InterestsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      icon: Icons.favorite_outline,
      title: 'Clinical interests',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final interest in profile.clinicalInterests)
            Chip(label: Text(interest)),
        ],
      ),
    );
  }
}
