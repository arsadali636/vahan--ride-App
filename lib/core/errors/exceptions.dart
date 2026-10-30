/// Application-level exceptions raised across the network/data layer.
///
/// [ApiException] is the single, typed exception surface exposed by the API
/// layer. Repositories map these into domain [Failure]s for the presentation
/// layer — [ApiException] must never leak into widgets.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// Extra error context extracted from the backend response body.
  final Map<String, dynamic>? details;

  const ApiException({required this.message, this.statusCode, this.details});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

/// The request could not reach the server (DNS, connection refused, offline).
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Network connection failed. Please try again.',
    super.statusCode,
    super.details,
  });
}

/// The request timed out before completing.
class NetworkTimeoutException extends ApiException {
  const NetworkTimeoutException({
    super.message = 'The request timed out. Please try again.',
    super.statusCode,
    super.details,
  });
}

/// 400 — the request payload is malformed.
class BadRequestException extends ApiException {
  const BadRequestException({
    super.message = 'The request was invalid.',
    super.statusCode = 400,
    super.details,
  });
}

/// 401 — missing or expired credentials.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Your session has expired. Please sign in again.',
    super.statusCode = 401,
    super.details,
  });
}

/// 403 — authenticated but not permitted to perform the action.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
    super.details,
  });
}

/// 404 — the requested resource does not exist.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
    super.details,
  });
}

/// 409 — the request conflicts with the current server state.
class ConflictException extends ApiException {
  const ConflictException({
    super.message = 'The request conflicts with the current state.',
    super.statusCode = 409,
    super.details,
  });
}

/// 422 — validation error. Backend FastAPI detail is a list of
/// `{loc, msg, type}` entries.
class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Some of the provided values are invalid.',
    super.statusCode = 422,
    super.details,
  });
}

/// 429 — too many requests; rate limit exceeded.
class RateLimitException extends ApiException {
  const RateLimitException({
    super.message = 'Too many requests. Please slow down and try again.',
    super.statusCode = 429,
    super.details,
  });
}

/// 5xx — server-side failure (500, 502, 503, ...).
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Something went wrong on our side. Please try again later.',
    super.statusCode,
    super.details,
  });
}

/// The request was cancelled (e.g. widget disposed, user aborted).
class RequestCancelledException extends ApiException {
  const RequestCancelledException({
    super.message = 'The request was cancelled.',
    super.details,
  });
}

/// Any status code / error shape that does not fit the known set.
class UnexpectedException extends ApiException {
  const UnexpectedException({
    super.message = 'An unexpected error occurred.',
    super.statusCode,
    super.details,
  });
}
