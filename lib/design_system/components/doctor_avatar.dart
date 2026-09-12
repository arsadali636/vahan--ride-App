import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

/// Circular doctor avatar showing the profile photo, or initials on a primary
/// background when no photo is available.
class DoctorAvatar extends StatelessWidget {
  final String? photoUrl;
  final String firstName;
  final String? lastName;
  final double size;
  final bool verified;

  const DoctorAvatar({
    super.key,
    this.photoUrl,
    required this.firstName,
    this.lastName,
    this.size = 48,
    this.verified = false,
  });

  String get _initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
    final last = (lastName != null && lastName!.isNotEmpty)
        ? lastName![0].toUpperCase()
        : '';
    return '$first$last';
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        image: hasPhoto
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? null
          : Text(
              _initials,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
                fontSize: size * 0.34,
              ),
            ),
    );

    if (!verified) return avatar;

    final ring = size * 0.42;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -ring * 0.15,
          bottom: -ring * 0.05,
          child: Container(
            width: ring,
            height: ring,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Icon(
              Icons.verified_rounded,
              size: ring * 0.7,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
