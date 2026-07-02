import 'package:flutter/material.dart';

/// Central color palette derived from the Alive brand (green gradient).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF34B233); // Alive green
  static const Color primaryDark = Color(0xFF1E8A1E);
  static const Color accent = Color(0xFFB7E92B); // lime/yellow-green
  static const Color highlight = Color(0xFFF4F900); // bright yellow

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF6F8F6);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color error = Color(0xFFD32F2F);

  // Form / input
  static const Color fieldFill = Color(0xFFF2F2F4);
  static const Color fieldLabel = Color(0xFF6E6E73);
  static const Color hint = Color(0xFFA0A0A5);

  // Home screen
  static const Color follow = Color(0xFFF2E21C); // bright yellow "+ Follow"
  static const Color chipBorder = Color(0xFFE6E6E8);
  static const Color chipActiveBg = Color(0xFFF1F9E6);
  static const Color inactiveTab = Color(0xFF9E9E9E);
  static const Color badge = Color(0xFFFF3B30);

  /// Vertical green → lime gradient for the bottom navigation bar.
  static const LinearGradient bottomNavGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, accent],
  );

  /// Horizontal lime → green gradient used on primary buttons.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accent, primary, primaryDark],
    stops: [0.0, 0.6, 1.0],
  );

  /// Diagonal gradient for the bottom wave panel (dark green → lime).
  static const LinearGradient waveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, accent],
    stops: [0.0, 0.55, 1.0],
  );

  /// Brand gradient used on the splash background.
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [highlight, accent, primary, primaryDark],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
}
