/// App-wide constant values. Keep magic numbers / strings out of widgets.
class AppConstants {
  AppConstants._();

  // App identity
  static const String appName = 'Alive';

  // Asset paths
  static const String logoPath = 'assets/images/logo.png';
  static const String googleLogoPath = 'assets/images/google_logo.svg';

  // Splash
  static const Duration splashDuration = Duration(seconds: 3);

  // Networking (replace with your real base URL)
  static const String baseUrl = 'https://api.example.com';
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
