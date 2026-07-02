import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// "or continue with" — centered label flanked by thin dividers. Designed to sit
/// on the green wave panel, so it uses white-on-transparent styling.
class OrDivider extends StatelessWidget {
  final String label;

  const OrDivider({super.key, this.label = 'or continue with'});

  @override
  Widget build(BuildContext context) {
    final line = Container(
      height: 1,
      color: Colors.white.withValues(alpha: 0.5),
    );

    return Row(
      children: [
        Expanded(child: line),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapM),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: line),
      ],
    );
  }
}
