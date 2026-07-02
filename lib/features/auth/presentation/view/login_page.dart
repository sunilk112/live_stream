import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/primary_gradient_button.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../viewmodel/login_viewmodel.dart';
import '../widgets/auth_wave_section.dart';
import '../widgets/or_divider.dart';

/// Login screen. Provides its [LoginViewModel] from the service locator, then
/// renders a responsive form (white) above the green wave panel (social logins).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => sl<LoginViewModel>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final vm = context.read<LoginViewModel>();
    final success = await vm.login(
      _identifierController.text,
      _passwordController.text,
    );
    if (!mounted) return;

    if (success) {
      _goToHome();
    } else {
      _showSnack(vm.errorMessage ?? 'Login failed. Please try again.');
    }
  }

  /// Navigates to the Home screen, replacing Login in the history so the back
  /// button doesn't return to the auth flow.
  void _goToHome() {
    if (!mounted) return;
    context.goNamed(AppRoutes.homeName);
  }

  Future<void> _onGoogleSignIn() async {
    final vm = context.read<LoginViewModel>();
    final success = await vm.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      // Bottom toast, shown ONLY on the Google path (this handler). The OS-level
      // toast survives the navigation to Home.
      final name = vm.googleUser?.name.trim() ?? '';
      Fluttertoast.showToast(
        msg: name.isEmpty ? 'Welcome! 👋' : 'Welcome $name 👋',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG,
      );
      _goToHome();
    } else if (vm.errorMessage != null) {
      _showSnack(vm.errorMessage!);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email or phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      // At rest the content exactly fills the viewport (no scroll). When the
      // keyboard opens, the viewport shrinks below the content's height, so the
      // SingleChildScrollView becomes scrollable and focused fields stay visible.
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // White form area.
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.pagePadding,
                        ),
                        child: _Centered(child: _buildForm(vm)),
                      ),
                    ),
                    // Flexible white gap — expands to fill a tall screen, and
                    // collapses to 0 (enabling scroll) when the keyboard is up.
                    const Spacer(),
                    // Green wave panel — social logins + sign-up, pinned bottom.
                    AuthWaveSection(child: _Centered(child: _buildSocial(vm))),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(LoginViewModel vm) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 34), // breathing room above the app icon
          const Center(child: BrandLogo(size: AppSizes.logoBadge)),
          const SizedBox(height: AppSizes.gapM),
          const Center(
            child: Text(
              'Welcome back! 👋',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Sign in to continue your live streaming journey.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.gapXl),
          AppTextField(
            label: 'Email ID or Phone Number',
            hint: 'Enter Registered Email or Phone No.',
            controller: _identifierController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateIdentifier,
          ),
          const SizedBox(height: AppSizes.gapM),
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            obscureText: vm.obscurePassword,
            textInputAction: TextInputAction.done,
            validator: _validatePassword,
            onSubmitted: (_) => _onLogin(),
            suffix: IconButton(
              onPressed: vm.togglePasswordVisibility,
              iconSize: 20,
              icon: Icon(
                vm.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.fieldLabel,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _showSnack('Forgot password coming soon'),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.gapL),
          PrimaryGradientButton(
            label: 'Login',
            isLoading: vm.isLoading,
            onPressed: _onLogin,
          ),
          // Guaranteed gap between the button and the wave, even when the form
          // grows (validation errors) and the flexible spacer collapses to 0.
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildSocial(LoginViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const OrDivider(),
        const SizedBox(height: AppSizes.gapM),
        SocialAuthButton(
          icon: SvgPicture.asset(
            AppConstants.googleLogoPath,
            width: 20,
            height: 20,
          ),
          label: 'Continue with Google',
          isLoading: vm.isGoogleLoading,
          onPressed: _onGoogleSignIn,
        ),
        const SizedBox(height: AppSizes.gapM),
        SocialAuthButton(
          icon: const FaIcon(
            FontAwesomeIcons.facebook,
            color: Color(0xFF1877F2),
            size: 22,
          ),
          label: 'Continue with Facebook',
          // TODO: replace with real Facebook OAuth; for now it enters the app.
          onPressed: () => _goToHome(),
        ),
        const SizedBox(height: AppSizes.gapL),
        _buildSignUpRow(),
        // Bottom breathing room above the home indicator.
        SizedBox(height: AppSizes.gapM + MediaQuery.viewPaddingOf(context).bottom),
      ],
    );
  }

  Widget _buildSignUpRow() {
    return GestureDetector(
      onTap: () => _showSnack('Sign up coming soon'),
      child: RichText(
        text: const TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Constrains content width on large screens and centers it, keeping the layout
/// responsive across phones and tablets.
class _Centered extends StatelessWidget {
  final Widget child;

  const _Centered({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: child,
      ),
    );
  }
}
