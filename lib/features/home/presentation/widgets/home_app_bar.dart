import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_logo.dart';

/// Home top bar: brand logo on the left, notification bell (with unread badge)
/// and a green gradient wallet/gift button on the right.
class HomeAppBar extends StatelessWidget {
  final int notificationCount;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onWalletTap;

  const HomeAppBar({
    super.key,
    this.notificationCount = 0,
    this.onNotificationsTap,
    this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandLogo(size: 46),
        const Spacer(),
        _NotificationBell(
          count: notificationCount,
          onTap: onNotificationsTap,
        ),
        const SizedBox(width: 14),
        _GradientCircleButton(
          icon: Icons.account_balance_wallet_outlined,
          onTap: onWalletTap,
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationBell({required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.fieldFill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF4A4A4A),
                size: 24,
              ),
            ),
            if (count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  decoration: BoxDecoration(
                    color: AppColors.badge,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1,
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

class _GradientCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _GradientCircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
