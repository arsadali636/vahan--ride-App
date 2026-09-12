import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_empty_view.dart';
import '../../../../design_system/components/app_section_header.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/components/status_chip.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/doctor_registration.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../dialogs/add_registration_dialog.dart';

/// Lists the profile's registrations with an add action.
class RegistrationsSection extends StatelessWidget {
  final List<DoctorRegistration> registrations;

  const RegistrationsSection({super.key, required this.registrations});

  Future<void> _onAdd(BuildContext context) async {
    final draft = await showAddRegistrationDialog(context);
    if (!context.mounted) return;
    if (draft == null) return;
    context.read<DoctorProfileBloc>().add(AddRegistrationRequested(draft));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Registrations',
          action: OutlineButton(
            label: 'Add',
            icon: Icons.add,
            onPressed: () => _onAdd(context),
          ),
        ),
        if (registrations.isEmpty)
          const AppEmptyView(
            title: 'No registrations yet',
            message: 'Add your council registrations.',
            icon: Icons.badge_outlined,
            fullScreen: false,
          )
        else
          for (final item in registrations)
            AppCard(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  _RegistrationBadge(icon: Icons.verified_user_outlined),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.councilId, style: AppTypography.bodyLarge),
                        Text(
                          '${item.registrationNumber} • ${item.registrationYear}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.isPrimary)
                    const StatusChip(
                      label: 'Primary',
                      tone: AppStatusTone.info,
                    ),
                ],
              ),
            ),
      ],
    );
  }
}

/// Small tinted square badge used as the leading element of a list row.
class _RegistrationBadge extends StatelessWidget {
  final IconData icon;

  const _RegistrationBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderMd,
      ),
      child: Icon(icon, size: 20, color: primary),
    );
  }
}
