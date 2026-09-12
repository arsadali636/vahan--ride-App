import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../components/app_app_bar.dart';
import '../components/app_bottom_sheet.dart';
import '../components/app_card.dart';
import '../components/app_dialog.dart';
import '../components/app_dropdown.dart';
import '../components/app_empty_view.dart';
import '../components/app_error_view.dart';
import '../components/app_loader.dart';
import '../components/app_section_header.dart';
import '../components/app_tab_bar.dart';
import '../components/app_text_field.dart';
import '../components/availability_badge.dart';
import '../components/button_shell.dart';
import '../components/doctor_avatar.dart';
import '../components/hospital_avatar.dart';
import '../components/outline_button.dart';
import '../components/primary_button.dart';
import '../components/search_field.dart';
import '../components/secondary_button.dart';
import '../components/status_chip.dart';
import '../components/verification_badge.dart';
import '../radius/app_radius.dart';
import '../shadows/app_shadows.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Temporary page showcasing every design system token and component.
/// Deleted once real feature screens exist.
class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});

  static const String routePath = '/design-system';
  static const String routeName = 'design-system';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppAppBar(
          title: 'Design System',
          bottom: const AppTabBar(
            tabs: ['Tokens', 'Buttons & Inputs', 'Cards & Avatars', 'States & Overlays'],
          ),
        ),
        body: const TabBarView(
          children: [
            _TokensTab(),
            _ButtonsAndInputsTab(),
            _CardsAndAvatarsTab(),
            _StatesAndOverlaysTab(),
          ],
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _PreviewSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: child,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment alignment;

  const _PreviewRow({required this.children, this.alignment = MainAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final String name;

  const _Swatch({required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.sm,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(name, style: AppTypography.caption),
      ],
    );
  }
}

class _TokensTab extends StatelessWidget {
  const _TokensTab();

  static const _colors = <(String, Color)>[
    ('primary', AppColors.primary),
    ('primaryDark', AppColors.primaryDark),
    ('secondary', AppColors.secondary),
    ('workforce', AppColors.workforce),
    ('background', AppColors.background),
    ('surface', AppColors.surface),
    ('surfaceMuted', AppColors.surfaceMuted),
    ('textPrimary', AppColors.textPrimary),
    ('textSecondary', AppColors.textSecondary),
    ('textDisabled', AppColors.textDisabled),
    ('border', AppColors.border),
    ('borderStrong', AppColors.borderStrong),
    ('success', AppColors.success),
    ('warning', AppColors.warning),
    ('error', AppColors.error),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewSection(
            title: 'Colors',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [for (final (name, color) in _colors) _Swatch(color: color, name: name)],
            ),
          ),
          _PreviewSection(
            title: 'Typography',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display Large', style: AppTypography.displayLarge),
                Text('Display Medium', style: AppTypography.displayMedium),
                Text('Heading Large', style: AppTypography.headingLarge),
                Text('Heading Medium', style: AppTypography.headingMedium),
                Text('Title Large', style: AppTypography.titleLarge),
                Text('Title Medium', style: AppTypography.titleMedium),
                Text('Title Small', style: AppTypography.titleSmall),
                Text('Body Large', style: AppTypography.bodyLarge),
                Text('Body Medium', style: AppTypography.bodyMedium),
                Text('Body Small', style: AppTypography.bodySmall),
                Text('Label Large', style: AppTypography.labelLarge),
                Text('Label Medium', style: AppTypography.labelMedium),
                Text('Label Small', style: AppTypography.labelSmall),
                Text('Caption', style: AppTypography.caption),
                Text('Overline', style: AppTypography.overline),
              ],
            ),
          ),
          _PreviewSection(
            title: 'Spacing',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: const [
                _SizePill(name: 'xxs', value: AppSpacing.xxs),
                _SizePill(name: 'xs', value: AppSpacing.xs),
                _SizePill(name: 'sm', value: AppSpacing.sm),
                _SizePill(name: 'md', value: AppSpacing.md),
                _SizePill(name: 'lg', value: AppSpacing.lg),
                _SizePill(name: 'xl', value: AppSpacing.xl),
                _SizePill(name: 'xxl', value: AppSpacing.xxl),
              ],
            ),
          ),
          _PreviewSection(
            title: 'Radius',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: const [
                _RadiusSwatch(name: 'xs', value: AppRadius.xs),
                _RadiusSwatch(name: 'sm', value: AppRadius.sm),
                _RadiusSwatch(name: 'md', value: AppRadius.md),
                _RadiusSwatch(name: 'lg', value: AppRadius.lg),
                _RadiusSwatch(name: 'xl', value: AppRadius.xl),
              ],
            ),
          ),
          _PreviewSection(
            title: 'Shadows',
            child: const _PreviewRow(
              children: [
                _ShadowSwatch(name: 'sm', shadows: AppShadows.sm),
                _ShadowSwatch(name: 'md', shadows: AppShadows.md),
                _ShadowSwatch(name: 'lg', shadows: AppShadows.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SizePill extends StatelessWidget {
  final String name;
  final double value;

  const _SizePill({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.borderMd,
      ),
      child: Text('$name\n${value.toInt()}'),
    );
  }
}

class _RadiusSwatch extends StatelessWidget {
  final String name;
  final double value;

  const _RadiusSwatch({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(value),
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        style: AppTypography.caption.copyWith(color: AppColors.textOnPrimary),
      ),
    );
  }
}

class _ShadowSwatch extends StatelessWidget {
  final String name;
  final List<BoxShadow> shadows;

  const _ShadowSwatch({required this.name, required this.shadows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        boxShadow: shadows,
      ),
      alignment: Alignment.center,
      child: Text(name, style: AppTypography.caption),
    );
  }
}

class _ButtonsAndInputsTab extends StatelessWidget {
  const _ButtonsAndInputsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewSection(
            title: 'Buttons',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PreviewRow(children: [
                  PrimaryButton(label: 'Primary', onPressed: null),
                  SecondaryButton(label: 'Secondary', onPressed: null),
                  OutlineButton(label: 'Outline', onPressed: null),
                ]),
                const _PreviewRow(children: [
                  PrimaryButton(label: 'Primary', onPressed: _noop, isLoading: true),
                  SecondaryButton(label: 'Secondary', onPressed: _noop, isLoading: true),
                  OutlineButton(label: 'Outline', onPressed: _noop, isLoading: true),
                ]),
                const _PreviewRow(children: [
                  PrimaryButton(label: 'Primary', onPressed: _noop, size: AppButtonSize.small),
                  PrimaryButton(label: 'Primary', onPressed: _noop, size: AppButtonSize.medium),
                  PrimaryButton(label: 'Primary', onPressed: _noop, size: AppButtonSize.large),
                ]),
                const _PreviewRow(children: [
                  PrimaryButton(label: 'Full width', onPressed: _noop, icon: Icons.add_rounded, fullWidth: true),
                ]),
              ],
            ),
          ),
          _PreviewSection(
            title: 'Text Field',
            child: const AppTextField(label: 'Label', hint: 'Hint text'),
          ),
          _PreviewSection(
            title: 'Text Field with error',
            child: const AppTextField(
              label: 'Email',
              error: 'Enter a valid email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          _PreviewSection(
            title: 'Text Field (obscured)',
            child: const AppTextField(
              label: 'Password',
              obscureText: true,
            ),
          ),
          _PreviewSection(
            title: 'Search Field',
            child: const SearchField(),
          ),
          _PreviewSection(
            title: 'Dropdown',
            child: AppDropdown<String>(
              label: 'Speciality',
              items: const ['Cardiology', 'Neurology', 'Dentistry', 'Dermatology'],
              initialValue: 'Cardiology',
              onChanged: _noop2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardsAndAvatarsTab extends StatelessWidget {
  const _CardsAndAvatarsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewSection(
            title: 'Card',
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card title', style: AppTypography.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Surface container with border and rounded corners.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          _PreviewSection(
            title: 'Card (shadow, tappable)',
            child: AppCard(
              hasShadow: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: const Text('Tap to see the ripple'),
            ),
          ),
          _PreviewSection(
            title: 'Status Chips',
            child: const _PreviewRow(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusChip(label: 'Profile Viewed', tone: AppStatusTone.info),
                StatusChip(label: 'Shortlisted', tone: AppStatusTone.success),
                StatusChip(label: 'Interview', tone: AppStatusTone.warning),
                StatusChip(label: 'Rejected', tone: AppStatusTone.error),
                StatusChip(label: 'Hired', tone: AppStatusTone.neutral),
              ],
            ),
          ),
          _PreviewSection(
            title: 'Badges',
            child: const _PreviewRow(children: [
              VerificationBadge(label: 'Verified'),
              AvailabilityBadge(label: 'Available'),
            ]),
          ),
          _PreviewSection(
            title: 'Avatars',
            child: const _PreviewRow(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                DoctorAvatar(firstName: 'Aarav', lastName: 'Sharma', size: 40),
                DoctorAvatar(firstName: 'Neha', lastName: 'Patel', size: 48, verified: true),
                DoctorAvatar(firstName: 'Rohan', lastName: 'Mehta', size: 56, verified: true),
                HospitalAvatar(hospitalName: 'Apollo', size: 48),
                HospitalAvatar(hospitalName: 'Fortis', size: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatesAndOverlaysTab extends StatelessWidget {
  const _StatesAndOverlaysTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewSection(
            title: 'Loader',
            child: const SizedBox(height: 72, child: AppLoader(label: 'Loading jobs...')),
          ),
          _PreviewSection(
            title: 'Error view',
            child: const SizedBox(
              height: 160,
              child: AppErrorView(
                title: 'Failed to load jobs',
                message: 'Check your connection and try again.',
              ),
            ),
          ),
          _PreviewSection(
            title: 'Empty view',
            child: const SizedBox(
              height: 180,
              child: AppEmptyView(
                title: 'No notifications yet',
                message: 'You are all caught up.',
              ),
            ),
          ),
          _PreviewSection(
            title: 'Overlays',
            child: Builder(
              builder: (context) {
                return const _PreviewRow(
                  children: [
                    _ShowSheetButton(),
                    _ShowDialogButton(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowSheetButton extends StatelessWidget {
  const _ShowSheetButton();

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      label: 'Open bottom sheet',
      onPressed: () => AppBottomSheet.show(
        context: context,
        title: 'Bottom sheet',
        child: const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text('This sheet uses the central bottom sheet theme.'),
        ),
      ),
    );
  }
}

class _ShowDialogButton extends StatelessWidget {
  const _ShowDialogButton();

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      label: 'Open dialog',
      onPressed: () => AppDialog.show(
        context: context,
        icon: Icons.check_circle_rounded,
        title: 'Verified',
        content: const Text('This dialog uses the central dialog theme.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

void _noop2(String? _) {}
