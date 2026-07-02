import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodel/splash_viewmodel.dart';

/// Splash screen — the first route. On a clean white canvas the Alive logo
/// resolves "into focus" (blur + scale + fade), gets a light shimmer sweep, and
/// floats over a softly breathing brand glow. Once the [SplashViewModel] reports
/// it is ready, the screen navigates to Home.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SplashViewModel()
      ..addListener(_onViewModelChanged)
      ..init();
  }

  void _onViewModelChanged() {
    if (_viewModel.isReady && mounted) {
      context.goNamed(AppRoutes.loginName);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<SplashViewModel>.value(
        value: _viewModel,
        child: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.splashGradient),
          child: Stack(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _BreathingGlow(),
                    _AnimatedLogo(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment(0, 0.8),
                child: _Footer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft radial brand-green halo that slowly pulses behind the logo, giving the
/// otherwise-static white screen a sense of life.
class _BreathingGlow extends StatelessWidget {
  const _BreathingGlow();

  @override
  Widget build(BuildContext context) {
    final dimension = _logoDimension(context) * 1.7;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 0.85,
          end: 1.12,
          duration: 1800.ms,
          curve: Curves.easeInOut,
        )
        .fade(begin: 0.5, end: 1.0, duration: 1800.ms);
  }
}

/// The Alive logo with a cinematic reveal: it starts slightly enlarged, blurred
/// and transparent, then resolves into a crisp, settled icon — followed by a
/// single light shimmer sweep. Falls back to an icon if the asset can't load.
class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo();

  @override
  Widget build(BuildContext context) {
    final dimension = _logoDimension(context);

    final logo = Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dimension * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        AppConstants.logoPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const ColoredBox(
          color: Colors.white,
          child: Icon(
            Icons.videocam_rounded,
            size: 90,
            color: AppColors.primary,
          ),
        ),
      ),
    );

    return logo
        .animate()
        // Phase 1 — resolve into focus.
        .fadeIn(duration: 900.ms, curve: Curves.easeOut)
        .scaleXY(
          begin: 1.18,
          end: 1.0,
          duration: 1100.ms,
          curve: Curves.easeOutCubic,
        )
        .blurXY(begin: 16, end: 0, duration: 900.ms, curve: Curves.easeOutCubic)
        // Phase 2 — a gentle settle, then a light sweep.
        .then(delay: 150.ms)
        .shimmer(
          duration: 1400.ms,
          color: Colors.white.withValues(alpha: 0.65),
        );
  }
}

/// Bottom tagline + loading indicator, fading up after the logo settles.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Go Live • Stay Alive',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 22),
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 700.ms)
        .slideY(begin: 0.5, end: 0, curve: Curves.easeOut);
  }
}

/// Responsive logo size, shared by the logo and its glow so they stay in sync.
double _logoDimension(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width * 0.52;
  return width.clamp(150.0, 240.0);
}
