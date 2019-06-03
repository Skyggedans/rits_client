abstract class AuthenticationError implements Exception {
  final String message;

  AuthenticationError(this.message);

  @override
  String toString() => message;
}

class AccessDeniedError extends AuthenticationError {
  AccessDeniedError() : super('Access Denied');
}

class RateLimitExceededError extends AuthenticationError {
  RateLimitExceededError() : super('Rate Limit Exceeded');
}

class AuthorizationPendingError extends AuthenticationError {
  AuthorizationPendingError() : super('Authorization Pending');
}

class InvalidUserCodeError extends AuthenticationError {
  InvalidUserCodeError() : super('Invalid User Code');
}

class InvalidGrantTypeError extends AuthenticationError {
  InvalidGrantTypeError() : super('Invalid Grant Type Requested');
}

class InvalidRequestError extends AuthenticationError {
  InvalidRequestError() : super('Invalid Request');
}

class TokenRevokedError extends AuthenticationError {
  TokenRevokedError() : super('Token Revoked');
}

class TokenExpiredError extends AuthenticationError {
  TokenExpiredError() : super('Token Expired');
}
