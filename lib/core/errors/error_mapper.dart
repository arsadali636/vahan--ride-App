import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Centralized error mapping.
///
/// 1. [ApiExceptionMapper] converts a raw [DioException] into a typed
///    [ApiException], parsing the backend error body (including the FastAPI
///    validation shape `{detail: [{loc, msg, type}]}`).
/// 2. [FailureMapper] converts an [ApiException] into a domain [Failure].
///
/// The status codes covered are: 400, 401, 403, 404, 409, 422, 429, and all
/// 5xx (500, 502, 503, ...). Only fields that actually exist in the backend
/// responses are parsed.
class ApiExceptionMapper {
  ApiExceptionMapper._();

  static ApiException fromDioException(DioException error) {
    if (error.error is ApiException) {
      return error.error! as ApiException;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return NetworkTimeoutException(statusCode: error.response?.statusCode);
      case DioExceptionType.connectionError:
        return NetworkException(
          statusCode: error.response?.statusCode,
          details: _extractDetails(error.response?.data),
        );
      case DioExceptionType.cancel:
        return RequestCancelledException(
          details: _extractDetails(error.response?.data),
        );
      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'A secure connection could not be established.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? -1;
        return _fromStatusCode(statusCode, error.response?.data);
      case DioExceptionType.unknown:
        return NetworkException(
          message: error.message ?? 'An unexpected network error occurred.',
          statusCode: error.response?.statusCode,
          details: _extractDetails(error.response?.data),
        );
    }
  }

  static ApiException _fromStatusCode(int statusCode, dynamic data) {
    final message = _extractMessage(data, statusCode);
    final details = _extractDetails(data);

    switch (statusCode) {
      case 400:
        return BadRequestException(message: message, details: details);
      case 401:
        return UnauthorizedException(message: message, details: details);
      case 403:
        return ForbiddenException(message: message, details: details);
      case 404:
        return NotFoundException(message: message, details: details);
      case 409:
        return ConflictException(message: message, details: details);
      case 422:
        return ValidationException(
          message: _extractValidationMessage(data) ?? message,
          details: details,
        );
      case 429:
        return RateLimitException(message: message, details: details);
      default:
        if (statusCode >= 500) {
          return ServerException(
            message: message,
            statusCode: statusCode,
            details: details,
          );
        }
        return UnexpectedException(
          message: message,
          statusCode: statusCode,
          details: details,
        );
    }
  }

  static String _extractMessage(dynamic data, int statusCode) {
    final detail = _extractDetails(data)?['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    return 'Request failed (HTTP $statusCode).';
  }

  /// FastAPI validation errors use `{detail: [{loc, msg, type}]}`.
  static String? _extractValidationMessage(dynamic data) {
    final details = _extractDetails(data);
    final detail = details?['detail'];
    if (detail is! List || detail.isEmpty) return null;

    final messages = <String>[];
    for (final item in detail) {
      if (item is! Map) continue;
      final loc = item['loc'];
      final msg = item['msg'];
      if (loc is List && loc.isNotEmpty && msg is String) {
        final field = loc.last;
        messages.add('$field: $msg');
      } else if (msg is String) {
        messages.add(msg);
      }
    }
    return messages.isEmpty ? null : messages.join('\n');
  }

  static Map<String, dynamic>? _extractDetails(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}

/// Maps a typed [ApiException] into a domain [Failure] for usecases.
class FailureMapper {
  FailureMapper._();

  static Failure fromApiException(ApiException exception) {
    if (exception is NetworkTimeoutException) {
      return NetworkTimeoutFailure(exception.message);
    }
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }
    if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message);
    }
    if (exception is ForbiddenException) {
      return ForbiddenFailure(exception.message);
    }
    if (exception is NotFoundException) {
      return NotFoundFailure(exception.message);
    }
    if (exception is ConflictException) {
      return ConflictFailure(exception.message);
    }
    if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    }
    if (exception is RateLimitException) {
      return RateLimitFailure(exception.message);
    }
    if (exception is RequestCancelledException) {
      return CancelledFailure(exception.message);
    }
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    }
    return UnexpectedFailure(exception.message);
  }

  static Failure fromException(Object error) {
    if (error is ApiException) return fromApiException(error);
    if (error is Failure) return error;
    return UnexpectedFailure(error.toString());
  }
}
