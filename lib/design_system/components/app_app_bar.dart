import 'package:flutter/material.dart';

/// Application top bar. Styling comes from the central `AppBarTheme`; this
/// widget standardizes the header slot.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBack;

  const AppAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.bottom,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: actions,
      leading: leading ??
          (automaticallyImplyLeading && Navigator.canPop(context)
              ? IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                )
              : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      elevation: elevation,
      scrolledUnderElevation: elevation,
      backgroundColor: backgroundColor,
      bottom: bottom,
    );
  }
}
