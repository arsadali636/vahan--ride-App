import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/models/user_model.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/components/status_chip.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Account tab: the caller's profile summary and app settings.
///
/// Reads the signed-in user from [AuthBloc]. Profile actions navigate to the
/// real profile features; the rest of the surface is a settings list.
class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, UserModel?>((bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user : null;
    });

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _ProfileHeaderCard(user: user),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _StatTile(icon: Icons.visibility_outlined, value: '0', label: 'Profile viewers'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatTile(
                    icon: Icons.insights_outlined,
                    value: '0',
                    label: 'Post impressions',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MenuGroup(children: [
            _MenuItem(
              icon: Icons.badge_outlined,
              title: 'My Profile',
              onTap: () => context.push(AppRouter.profileRoute),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings & Privacy',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.logout_rounded,
              title: 'Sign out',
              destructive: true,
              onTap: () => context.read<AuthBloc>().signOut(),
            ),
          ]),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final UserModel? user;

  const _ProfileHeaderCard({this.user});

  @override
  Widget build(BuildContext context) {
    final firstName = user?.firstName ?? 'Doctor';
    final lastName = user?.lastName;
    final headline = user?.professionalHeadline;
    final qualification = user?.qualification;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppCard(
        hasShadow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorAvatar(
                  photoUrl: user?.profileImage,
                  firstName: firstName,
                  lastName: lastName,
                  size: 64,
                  verified: user?.verificationStatus != null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$firstName ${lastName ?? ''}'.trim(),
                        style: AppTypography.titleLarge,
                      ),
                      if (headline != null && headline.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(headline, style: AppTypography.bodyMedium),
                      ],
                      if (qualification != null && qualification.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(qualification, style: AppTypography.bodySmall),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      const StatusChip(
                        label: 'Open to work',
                        tone: AppStatusTone.success,
                        icon: Icons.waving_hand_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    label: 'Edit profile',
                    icon: Icons.edit_outlined,
                    onPressed: () => context.push(AppRouter.editProfileRoute),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTypography.titleMedium),
              Text(label, style: AppTypography.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;

  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: AppTypography.bodyLarge.copyWith(color: color)),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
