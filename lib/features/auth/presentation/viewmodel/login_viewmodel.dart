import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';

enum LoginStatus { idle, loading, success, error }

/// MVVM ViewModel for the login screen. Owns form-independent UI state
/// (password visibility, request status) and orchestrates the auth use cases.
/// Holds no widgets — the View binds to it via Provider.
class LoginViewModel extends ChangeNotifier {
  final LoginUser _loginUser;
  final SignInWithGoogle _signInWithGoogle;

  LoginViewModel(this._loginUser, this._signInWithGoogle);

  LoginStatus _status = LoginStatus.idle;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;
  UserEntity? _googleUser;

  LoginStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _status == LoginStatus.loading;
  bool get isGoogleLoading => _isGoogleLoading;

  /// The user returned by the most recent successful Google sign-in. Only set on
  /// the Google path — used for the "Welcome …" toast.
  UserEntity? get googleUser => _googleUser;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Attempts email/phone + password login. Returns `true` on success.
  Future<bool> login(String identifier, String password) async {
    _status = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _loginUser(
      LoginParams(identifier: identifier.trim(), password: password),
    );

    return result.fold(
      (failure) {
        _status = LoginStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _status = LoginStatus.success;
        notifyListeners();
        return true;
      },
    );
  }

  /// Signs in with Google via Firebase. Returns `true` on success. A user
  /// cancellation is not an error (returns `false`, leaves [errorMessage] null).
  Future<bool> signInWithGoogle() async {
    _isGoogleLoading = true;
    _errorMessage = null;
    _googleUser = null;
    notifyListeners();

    final result = await _signInWithGoogle(const NoParams());

    return result.fold(
      (failure) {
        _isGoogleLoading = false;
        // Silent on cancellation; surface everything else.
        _errorMessage = failure is AuthCancelledFailure ? null : failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _isGoogleLoading = false;
        _googleUser = user;
        _status = LoginStatus.success;
        notifyListeners();
        return true;
      },
    );
  }
}
