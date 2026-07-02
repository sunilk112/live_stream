import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';

/// The bottom panel of the auth screens: a green, gradient-filled region whose
/// top edge is a smooth double "hill" wave (matching the design). A second,
/// darker wave sits behind the front one for depth.
///
/// [child] is laid out below the wave crests (top padding clears them).
class AuthWaveSection extends StatelessWidget {
  final Widget child;

  const AuthWaveSection({super.key, required this.child});

  /// Vertical room reserved for the wave crests before content begins. Must be
  /// greater than the clipper's deepest valley so content never overlaps it.
  static const double _crestZone = 64;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Back wave (darker, slightly higher) — purely decorative depth.
        Positioned.fill(
          child: ClipPath(
            clipper: _WaveClipper(lift: 18),
            child: const ColoredBox(color: AppColors.primaryDark),
          ),
        ),
        // Front wave carries the gradient and the content.
        ClipPath(
          clipper: _WaveClipper(),
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: AppColors.waveGradient),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                _crestZone,
                AppSizes.pagePadding,
                AppSizes.gapS,
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/// Clips a path with two hill crests and a central valley along the top edge.
/// [lift] raises the whole wave by a few pixels (used for the back layer).
class _WaveClipper extends CustomClipper<Path> {
  final double lift;

  const _WaveClipper({this.lift = 0});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()..moveTo(0, 40 - lift);

    // First hill (left).
    path.cubicTo(
      w * 0.12, 8 - lift,
      w * 0.25, 6 - lift,
      w * 0.34, 30 - lift,
    );
    // Central valley (kept shallow so it stays above the content padding).
    path.cubicTo(
      w * 0.43, 42 - lift,
      w * 0.50, 46 - lift,
      w * 0.58, 40 - lift,
    );
    // Second hill (right).
    path.cubicTo(
      w * 0.74, 22 - lift,
      w * 0.88, 4 - lift,
      w, 20 - lift,
    );

    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => oldClipper.lift != lift;
}
