/// Single source of truth for spacing, radii and component dimensions so the
/// whole UI stays on a consistent rhythm ("everything equal").
class AppSizes {
  AppSizes._();

  // Page
  static const double pagePadding = 20;
  static const double maxContentWidth = 480; // tablets / large screens

  // Spacing scale
  static const double gapXs = 8;
  static const double gapS = 12;
  static const double gapM = 16;
  static const double gapL = 24;
  static const double gapXl = 32;
  static const double gapXxl = 40;

  // Inputs
  static const double fieldHeight = 54;
  static const double fieldRadius = 16;

  // Buttons
  static const double buttonHeight = 54;
  static const double buttonRadius = 28;

  // Logo
  static const double logoBadge = 70;
}
