import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// Rounded-square avatar for hospital / workplace profiles. Shows the logo or
/// a building icon on the secondary brand color.
class HospitalAvatar extends StatelessWidget {
  final String? logoUrl;
  final String? hospitalName;
  final double size;

  const HospitalAvatar({
    super.key,
    this.logoUrl,
    this.hospitalName,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    final radius = size * 0.28;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(radius),
        image: hasLogo
            ? DecorationImage(image: NetworkImage(logoUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: hasLogo
          ? null
          : Icon(
              Icons.local_hospital_rounded,
              size: size * 0.5,
              color: AppColors.textOnPrimary,
            ),
    );
  }
}
