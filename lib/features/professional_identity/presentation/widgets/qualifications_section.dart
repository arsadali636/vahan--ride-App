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
import '../../domain/entities/doctor_qualification.dart';
import '../bloc/doctor_profile_bloc.dart';
import '../bloc/doctor_profile_event.dart';
import '../dialogs/add_qualification_dialog.dart';

/// Lists the profile's qualifications with add and delete actions.
class QualificationsSection extends StatelessWidget {
  final List<DoctorQualification> qualifications;

  const QualificationsSection({super.key, required this.qualifications});

  Future<void> _onAdd(BuildContext context) async {
    final draft = await showAddQualificationDialog(context);
    if (!context.mounted) return;
    if (draft == null) return;
    context.read<DoctorProfileBloc>().add(AddQualificationRequested(draft));
  }

  Future<void> _onDelete(BuildContext context, DoctorQualification item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove qualification?'),
        content: Text('${item.degree} at ${item.institution} will be removed.'),
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
      context
          .read<DoctorProfileBloc>()
          .add(DeleteQualificationRequested(item.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Qualifications',
          action: OutlineButton(
            label: 'Add',
            icon: Icons.add,
            onPressed: () => _onAdd(context),
          ),
        ),
        if (qualifications.isEmpty)
          const AppEmptyView(
            title: 'No qualifications yet',
            message: 'Add your degrees to build your professional profile.',
            icon: Icons.school_outlined,
            fullScreen: false,
          )
        else
          for (final item in qualifications)
            AppCard(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  _LeadingBadge(icon: Icons.school_outlined),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.degree, style: AppTypography.bodyLarge),
                        if (item.specialization != null &&
                            item.specialization!.isNotEmpty)
                          Text(
                            item.specialization!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        Text(
                          '${item.institution} • ${item.year}',
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
class _LeadingBadge extends StatelessWidget {
  final IconData icon;

  const _LeadingBadge({required this.icon});

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
