import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../viewmodel/home_viewmodel.dart';

/// The "Stream / Hot / Follow" tabs. Active tab is green + bold.
class StreamTabBar extends StatelessWidget {
  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  const StreamTabBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _tabs = <(HomeTab, String)>[
    (HomeTab.stream, 'Stream'),
    (HomeTab.hot, 'Hot'),
    (HomeTab.follow, 'Follow'),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 26),
              _TabItem(
                label: _tabs[i].$2,
                active: _tabs[i].$1 == selected,
                onTap: () => onSelected(_tabs[i].$1),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? AppColors.primary : AppColors.inactiveTab,
        ),
      ),
    );
  }
}
