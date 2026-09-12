import 'package:flutter/material.dart';

import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Tab bar wrapper using the central [TabBarTheme].
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController? controller;
  final bool isScrollable;
  final EdgeInsetsGeometry padding;
  final void Function(int)? onTap;

  const AppTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    this.onTap,
  });

  @override
  Size get preferredSize {
    final resolved = padding.resolve(TextDirection.ltr);
    return Size.fromHeight(kTextTabBarHeight + resolved.top + resolved.bottom);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: padding,
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        onTap: onTap,
        labelStyle: AppTypography.labelLarge,
        tabs: [for (final tab in tabs) Tab(text: tab)],
      ),
    );
  }
}
