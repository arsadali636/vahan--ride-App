import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_empty_view.dart';
import '../../../../design_system/components/app_section_header.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/doctor_experience.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../dialogs/add_experience_dialog.dart';

/// Lists the profile's work-experience entries with add and delete actions.
class ExperiencesSection extends StatelessWidget {
  final List<DoctorExperience> experiences;

  const ExperiencesSection({super.key, required this.experiences});

  Future<void> _onAdd(BuildContext context) async {
    final draft = await showAddExperienceDialog(context);
    if (!context.mounted) return;
    if (draft == null) return;
    context.read<DoctorProfileBloc>().add(AddExperienceRequested(draft));
  }

  Future<void> _onDelete(BuildContext context, DoctorExperience item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove experience?'),
        content: Text('${item.role} at ${item.hospitalName} will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true && item.id != null) {
      context.read<DoctorProfileBloc>().add(
        DeleteExperienceRequested(item.id!),
      );
    }
  }

  String _period(DoctorExperience item) {
    final start = item.startDate;
    final end = item.endDate;
    if (item.isCurrent) return '${start ?? '?'} — Present';
    if (start != null && end != null) return '$start — $end';
    return start ?? end ?? 'Date unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Experience',
          action: OutlineButton(
            label: 'Add',
            icon: Icons.add,
            onPressed: () => _onAdd(context),
          ),
        ),
        if (experiences.isEmpty)
          const AppEmptyView(
            title: 'No experience yet',
            message: 'Add your work history to complete your profile.',
            icon: Icons.work_outline,
            fullScreen: false,
          )
        else
          for (final item in experiences)
            AppCard(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  _ExperienceBadge(icon: Icons.work_outline),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.role, style: AppTypography.bodyLarge),
                        Text(
                          item.hospitalName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (item.location != null)
                          Text(
                            item.location!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        Text(
                          _period(item),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                    onPressed: () => _onDelete(context, item),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

/// Small tinted square badge used as the leading element of a list row.
class _ExperienceBadge extends StatelessWidget {
  final IconData icon;

  const _ExperienceBadge({required this.icon});

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
