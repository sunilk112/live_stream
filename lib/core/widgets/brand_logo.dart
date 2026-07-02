import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Reusable app-icon badge: the Alive logo on a white rounded card with a soft
/// shadow. Used on the login/auth screens (and anywhere a compact brand mark is
/// needed). Gracefully falls back to an icon if the asset is missing.
class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({super.key, this.size = 68});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: Image.asset(
        AppConstants.logoPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.videocam_rounded,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
