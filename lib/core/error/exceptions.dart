/// Exceptions live in the DATA layer. Data sources throw these; repository
/// implementations catch them and convert them into [Failure]s.
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error']);
}

/// Thrown when the user cancels an interactive auth flow (Google dialog).
class AuthCancelledException implements Exception {
  const AuthCancelledException();
}
