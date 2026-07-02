import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';

/// MVVM ViewModel for the splash screen.
///
/// Holds NO UI code. It exposes [isReady] state and notifies the View when the
/// splash duration has elapsed so the View can navigate away. This is where
/// startup work (session restore, config fetch, etc.) would be awaited before
/// flipping `isReady`.
class SplashViewModel extends ChangeNotifier {
  bool _isReady = false;
  bool _disposed = false;
  Timer? _timer;

  bool get isReady => _isReady;

  /// Kicks off the splash lifecycle. Call once from the View's initState.
  void init() {
    _timer = Timer(AppConstants.splashDuration, () {
      _isReady = true;
      _safeNotify();
    });
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
