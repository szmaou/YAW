class ServerException implements Exception {
  ServerException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

class CacheException implements Exception {
  const CacheException(this.message);
  final String message;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;
}
