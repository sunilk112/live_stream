import 'package:equatable/equatable.dart';

/// Failures live in the DOMAIN layer. Use cases / repositories return these
/// (via `Either<Failure, T>`) instead of throwing, so the presentation layer
/// can handle errors declaratively.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to read local data.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}

/// The user aborted an interactive flow (e.g. dismissed the Google dialog).
/// The presentation layer should treat this as a no-op, not an error.
class AuthCancelledFailure extends Failure {
  const AuthCancelledFailure([super.message = 'Sign-in cancelled.']);
}
