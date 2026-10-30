import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/components/doctor_avatar.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';

/// Clean top app bar for DocConnect Pro home feed.
class DocConnectHeader extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? currentUser;
  final int unreadNotifications;
  final int unreadMessages;
  final VoidCallback? onAvatarTap;

  const DocConnectHeader({
    super.key,
    this.currentUser,
    this.unreadNotifications = 0,
    this.unreadMessages = 0,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final firstName = currentUser?.firstName ?? 'Doctor';
    final lastName = currentUser?.lastName;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.8),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          child: Row(
            children: [
              // ── Profile Avatar (Left) ──────────────────────────────────
              GestureDetector(
                onTap:
                    onAvatarTap ??
                    () {
                      context.push(AppRouter.profileRoute);
                    },
                child: DoctorAvatar(
                  photoUrl: UrlUtils.resolveUrl(currentUser?.profileImage),
                  firstName: firstName,
                  lastName: lastName,
                  size: 38,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // ── DocConnect Pro Title ──────────────────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DocConnect ',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTypography.wBold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Pro',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppTypography.wBold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
