// Named params can't bind private fields, so the initializer list is required.
// ignore_for_file: prefer_initializing_formals
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/auth_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Contract for the remote authentication source.
abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String identifier,
    required String password,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Lazy providers: `FirebaseAuth.instance` throws until Firebase is
  // initialized, so we only resolve these when Google sign-in actually runs —
  // keeping the mock email/password path (and the login screen) working even
  // before Firebase is configured.
  final FirebaseAuth Function() _firebaseAuth;
  final GoogleSignIn Function() _googleSignIn;

  bool _googleInitialized = false;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth Function() firebaseAuth,
    required GoogleSignIn Function() googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

  // ---------------------------------------------------------------------------
  // Mock email / password (unchanged)
  // ---------------------------------------------------------------------------
  @override
  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (password.toLowerCase() == 'wrong') {
      throw const ServerException('Invalid credentials. Please try again.');
    }
    return UserModel.fromJson({
      'id': '1',
      'name': 'Alive User',
      'email': identifier,
      'access_token': 'mock-token-123',
    });
  }

  // ---------------------------------------------------------------------------
  // Google (Firebase)
  // ---------------------------------------------------------------------------
  Future<void> _ensureGoogleInitialized(GoogleSignIn googleSignIn) async {
    if (_googleInitialized) return;
    await googleSignIn.initialize(
      serverClientId: AuthConfig.googleServerClientId.isEmpty
          ? null
          : AuthConfig.googleServerClientId,
    );
    _googleInitialized = true;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final googleSignIn = _googleSignIn();
    await _ensureGoogleInitialized(googleSignIn);

    if (!googleSignIn.supportsAuthenticate()) {
      throw const ServerException(
        'Google sign-in is not supported on this platform.',
      );
    }

    final GoogleSignInAccount account;
    try {
      account = await googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      throw ServerException(e.description ?? 'Google sign-in failed.');
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const ServerException(
        'Missing Google ID token — set AuthConfig.googleServerClientId '
        '(your Web client ID).',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _firebaseAuth().signInWithCredential(
      credential,
    );
    final user = userCredential.user;
    if (user == null) {
      throw const ServerException('Firebase sign-in failed.');
    }

    return UserModel.fromFirebase(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      token: idToken,
    );
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn().signOut();
    await _firebaseAuth().signOut();
  }
}
