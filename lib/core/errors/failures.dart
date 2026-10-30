import 'package:equatable/equatable.dart';

/// Domain-level failure. Repository implementations catch [ApiException]s and
/// convert them into a [Failure] so the presentation layer never depends on
/// transport details.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

class NetworkTimeoutFailure extends Failure {
  const NetworkTimeoutFailure([super.message = 'The request timed out']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server failure occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Permission denied']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class ConflictFailure extends Failure {
  const ConflictFailure([
    super.message = 'Request conflicts with server state',
  ]);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([
    super.message = 'Too many requests. Try again later',
  ]);
}

class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Request was cancelled']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error occurred']);
}
