import 'package:flutter/material.dart';

import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/radius/app_radius.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';

/// Identifies one slot of the main [MainNavigationBar].
enum MainTab { home, network, jobs, account }

/// Premium Floating 3D Bottom Navigation Bar for DocConnect Pro.
///
/// Features a rounded floating white container, centered elevated blue `+`
/// create button, active blue indicator line, and clean typography.
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
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        height: 66,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ── Floating White Navigation Bar ──────────────────────────
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Home',
                      icon: Icons.home_rounded,
                      selectedIcon: Icons.home_rounded,
                      selected: selected == MainTab.home,
                      onTap: () => onTabSelected(MainTab.home),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Network',
                      icon: Icons.people_outline_rounded,
                      selectedIcon: Icons.people_rounded,
                      selected: selected == MainTab.network,
                      onTap: () => onTabSelected(MainTab.network),
                    ),
                  ),
                  const SizedBox(width: 64), // Space for centered Create button
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
                      label: 'Profile',
                      icon: Icons.person_outline_rounded,
                      selectedIcon: Icons.person_rounded,
                      selected: selected == MainTab.account,
                      onTap: () => onTabSelected(MainTab.account),
                    ),
                  ),
                ],
              ),
            ),

            // ── Centered Elevated Blue '+' Create Button ──────────────
            Positioned(
              top: -12,
              child: Tooltip(
                message: 'Create a post',
                child: GestureDetector(
                  onTap: onPostPressed,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    final activeColor = AppColors.navActive;
    final inactiveColor = AppColors.navInactive;
    final color = selected ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderCircular,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? selectedIcon : icon, size: 22, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: selected
                  ? AppTypography.wSemiBold
                  : AppTypography.wMedium,
            ),
          ),
          if (selected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 16,
              height: 2.5,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
