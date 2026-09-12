import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';

/// Network tab: connections, invitations and discovery.
///
/// Design-first surface — invitation and suggestion data is demo content used
/// to shape the layout; discovery links to the real doctor search feature.
class NetworkTab extends StatelessWidget {
  const NetworkTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Network')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _DiscoveryCard(onTap: () => context.push(AppRouter.doctorNetworkRoute)),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text('Invitations', style: AppTypography.headingMedium),
          ),
          for (final invite in _demoInvitations)
            _InvitationCard(invite: invite),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              'People you may know',
              style: AppTypography.headingMedium,
            ),
          ),
          for (final person in _demoSuggestions)
            _SuggestionCard(person: person),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Entry point to the real doctor discovery feature.
class _DiscoveryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DiscoveryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppCard(
        hasShadow: true,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage my network',
                    style: AppTypography.titleSmall,
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Find and connect with fellow doctors',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Connection {
  final String firstName;
  final String? lastName;
  final String headline;

  const _Connection({
    required this.firstName,
    this.lastName,
    required this.headline,
  });
}

const List<_Connection> _demoInvitations = [
  _Connection(
    firstName: 'Kavya',
    lastName: 'Sharma',
    headline: 'Radiologist • Sunrise Diagnostics',
  ),
  _Connection(
    firstName: 'Arjun',
    lastName: 'Verma',
    headline: 'General Surgeon • Apollo Institute',
  ),
  _Connection(
    firstName: 'Nisha',
    lastName: 'Reddy',
    headline: 'Gynecologist • WomenFirst Clinic',
  ),
];

const List<_Connection> _demoSuggestions = [
  _Connection(
    firstName: 'Vikram',
    lastName: 'Singh',
    headline: 'Neurologist • Max Brain Centre',
  ),
  _Connection(
    firstName: 'Ananya',
    lastName: 'Kulkarni',
    headline: 'Dermatologist • DermCare Studio',
  ),
  _Connection(
    firstName: 'Ishaan',
    lastName: 'Gupta',
    headline: 'Anesthesiologist • City General Hospital',
  ),
];

class _InvitationCard extends StatelessWidget {
  final _Connection invite;

  const _InvitationCard({required this.invite});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoctorAvatar(
            firstName: invite.firstName,
            lastName: invite.lastName,
            size: 48,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.firstName,
                  style: AppTypography.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(invite.headline, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Accept',
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlineButton(
                        label: 'Decline',
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final _Connection person;

  const _SuggestionCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DoctorAvatar(
            firstName: person.firstName,
            lastName: person.lastName,
            size: 48,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.firstName, style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(person.headline, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: () {},
                  borderRadius: AppRadius.borderCircular,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderCircular,
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      'Connect',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: AppTypography.wSemiBold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
