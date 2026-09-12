import 'package:flutter/material.dart';

import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/shadows/app_shadows.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';

/// Identifies one slot of the main [MainNavigationBar].
enum MainTab { home, network, jobs, account }

/// LinkedIn-style bottom navigation with a centered, raised Post button.
///
/// The four regular tabs (Home, Network, Jobs, Me) are evenly spaced with the
/// highlighted Post action pinned in the middle. The selected tab is tinted
/// with the brand color; the Post button is always the primary call to action.
class MainNavigationBar extends StatelessWidget {
  final MainTab selected;
  final ValueChanged<MainTab> onTabSelected;
  final VoidCallback onPostPressed;

  const MainNavigationBar({
    super.key,
    required this.selected,
    required this.onTabSelected,
    required this.onPostPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: AppShadows.sm,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  selected: selected == MainTab.home,
                  onTap: () => onTabSelected(MainTab.home),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'Network',
                  icon: Icons.people_alt_outlined,
                  selectedIcon: Icons.people_alt_rounded,
                  selected: selected == MainTab.network,
                  onTap: () => onTabSelected(MainTab.network),
                ),
              ),
              SizedBox(width: 72, child: _PostButton(onPressed: onPostPressed)),
              Expanded(
                child: _TabButton(
                  label: 'Jobs',
                  icon: Icons.work_outline_rounded,
                  selectedIcon: Icons.work_rounded,
                  selected: selected == MainTab.jobs,
                  onTap: () => onTabSelected(MainTab.jobs),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'Me',
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  selected: selected == MainTab.account,
                  onTap: () => onTabSelected(MainTab.account),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderMd,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? selectedIcon : icon, size: 24, color: color),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: selected ? AppTypography.wSemiBold : AppTypography.wMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// The raised circular "+" action that opens the post composer.
class _PostButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PostButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: Tooltip(
          message: 'Create a post',
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: AppShadows.md,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 30,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
