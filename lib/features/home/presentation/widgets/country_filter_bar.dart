import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Horizontally scrollable country filter chips (Global, India, …).
class CountryFilterBar extends StatelessWidget {
  final List<({String label, String flag})> countries;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsets padding;

  const CountryFilterBar({
    super.key,
    required this.countries,
    required this.selectedIndex,
    required this.onSelected,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: countries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final c = countries[index];
          return _CountryChip(
            label: c.label,
            flag: c.flag,
            active: index == selectedIndex,
            onTap: () => onSelected(index),
          );
        },
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  final String label;
  final String flag;
  final bool active;
  final VoidCallback onTap;

  const _CountryChip({
    required this.label,
    required this.flag,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.chipActiveBg : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.chipBorder,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColors.textPrimary : const Color(0xFF6B6B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
