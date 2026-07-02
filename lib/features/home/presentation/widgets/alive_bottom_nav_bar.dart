import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Destinations in the bottom bar (excludes the central Go Live action).
enum AliveNavTab { home, party, chats, profile }

/// Custom bottom navigation: a green gradient bar with rounded top corners and
/// an elevated circular "Go Live" button floating over its center.
class AliveBottomNavBar extends StatelessWidget {
  final AliveNavTab current;
  final ValueChanged<AliveNavTab> onSelected;
  final VoidCallback? onGoLive;

  const AliveBottomNavBar({
    super.key,
    required this.current,
    required this.onSelected,
    this.onGoLive,
  });

  static const double _raise = 30;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final barHeight = 66 + bottomInset;

    return SizedBox(
      height: barHeight + _raise,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: barHeight,
              decoration: const BoxDecoration(
                gradient: AppColors.bottomNavGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.only(bottom: bottomInset, top: 8),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    active: current == AliveNavTab.home,
                    onTap: () => onSelected(AliveNavTab.home),
                  ),
                  _NavItem(
                    icon: Icons.celebration_outlined,
                    label: 'Party',
                    active: current == AliveNavTab.party,
                    onTap: () => onSelected(AliveNavTab.party),
                  ),
                  const _GoLiveLabelSlot(),
                  _NavItem(
                    icon: Icons.send_outlined,
                    label: 'Chats',
                    active: current == AliveNavTab.chats,
                    onTap: () => onSelected(AliveNavTab.chats),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    active: current == AliveNavTab.profile,
                    onTap: () => onSelected(AliveNavTab.profile),
                  ),
                ],
              ),
            ),
          ),
          // Elevated center Go Live button.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: _GoLiveButton(onTap: onGoLive)),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : Colors.white.withValues(alpha: 0.9);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reserves the center column and shows the "Go Live" label under the floating
/// button.
class _GoLiveLabelSlot extends StatelessWidget {
  const _GoLiveLabelSlot();

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text(
            'Go Live',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoLiveButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _GoLiveButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.wifi_tethering_rounded,
          color: AppColors.primary,
          size: 30,
        ),
      ),
    );
  }
}
