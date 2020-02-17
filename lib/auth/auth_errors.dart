abstract class AuthError implements Exception {
  final String message;

  AuthError(this.message);

  @override
  String toString() => message;
}

class AccessDeniedError extends AuthError {
  AccessDeniedError() : super('Access Denied');
}

class RateLimitExceededError extends AuthError {
  RateLimitExceededError() : super('Rate Limit Exceeded');
}

class AuthorizationPendingError extends AuthError {
  AuthorizationPendingError() : super('Authorization Pending');
}

class InvalidUserCodeError extends AuthError {
  InvalidUserCodeError() : super('Invalid User Code');
}

class InvalidGrantTypeError extends AuthError {
  InvalidGrantTypeError() : super('Invalid Grant Type Requested');
}

class InvalidRequestError extends AuthError {
  InvalidRequestError() : super('Invalid Request');
}

class TokenRevokedError extends AuthError {
  TokenRevokedError() : super('Token Revoked');
}

class TokenExpiredError extends AuthError {
  TokenExpiredError() : super('Token Expired');
}
