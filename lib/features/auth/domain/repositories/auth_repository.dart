import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// DOMAIN-layer contract for authentication. The presentation layer depends on
/// this abstraction only.
abstract class AuthRepository {
  /// Logs in with an email/phone identifier and a password.
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  });

  /// Signs the user in with Google via Firebase Authentication.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Signs the current user out of Firebase and Google.
  Future<Either<Failure, Unit>> signOut();
}
