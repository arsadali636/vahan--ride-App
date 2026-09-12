import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/errors/error_mapper.dart';
import 'package:doc_connect_app/core/errors/exceptions.dart';
import 'package:doc_connect_app/core/errors/failures.dart';

void main() {
  DioException dioError({
    DioExceptionType type = DioExceptionType.badResponse,
    int? statusCode,
    dynamic data,
    String? message,
  }) {
    final requestOptions = RequestOptions(path: '/endpoint');
    return DioException(
      requestOptions: requestOptions,
      type: type,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: requestOptions,
              statusCode: statusCode,
              data: data,
            ),
      message: message,
    );
  }

  group('ApiExceptionMapper.fromDioException — transport', () {
    test('maps connection timeout', () {
      final result = ApiExceptionMapper.fromDioException(
        dioError(type: DioExceptionType.connectionTimeout),
      );
      expect(result, isA<NetworkTimeoutException>());
    });

    test('maps send timeout', () {
      final result = ApiExceptionMapper.fromDioException(
        dioError(type: DioExceptionType.sendTimeout),
      );
      expect(result, isA<NetworkTimeoutException>());
    });

    test('maps receive timeout', () {
      final result = ApiExceptionMapper.fromDioException(
        dioError(type: DioExceptionType.receiveTimeout),
      );
      expect(result, isA<NetworkTimeoutException>());
    });

    test('maps connection error', () {
      final result = ApiExceptionMapper.fromDioException(
        dioError(type: DioExceptionType.connectionError),
      );
      expect(result, isA<NetworkException>());
    });

    test('maps request cancellation', () {
      final result = ApiExceptionMapper.fromDioException(
        dioError(type: DioExceptionType.cancel),
      );
      expect(result, isA<RequestCancelledException>());
    });

    test('maps unknown errors to a network exception', () {
      final result = ApiExceptionMapper.fromDioException(
        dioError(type: DioExceptionType.unknown, message: 'boom'),
      );
      expect(result, isA<NetworkException>());
    });
  });

  group('ApiExceptionMapper.fromDioException — status codes', () {
    test('400 → BadRequestException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 400)),
        isA<BadRequestException>(),
      );
    });

    test('401 → UnauthorizedException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 401)),
        isA<UnauthorizedException>(),
      );
    });

    test('403 → ForbiddenException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 403)),
        isA<ForbiddenException>(),
      );
    });

    test('404 → NotFoundException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 404)),
        isA<NotFoundException>(),
      );
    });

    test('409 → ConflictException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 409)),
        isA<ConflictException>(),
      );
    });

    test('422 → ValidationException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 422)),
        isA<ValidationException>(),
      );
    });

    test('429 → RateLimitException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 429)),
        isA<RateLimitException>(),
      );
    });

    test('500 → ServerException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 500)),
        isA<ServerException>(),
      );
    });

    test('502 → ServerException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 502)),
        isA<ServerException>(),
      );
    });

    test('503 → ServerException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 503)),
        isA<ServerException>(),
      );
    });

    test('unmapped status (418) → UnexpectedException', () {
      expect(
        ApiExceptionMapper.fromDioException(dioError(statusCode: 418)),
        isA<UnexpectedException>(),
      );
    });
  });

  group('ApiExceptionMapper — error body parsing', () {
    test('uses the FastAPI detail string as the message', () {
      final result = ApiExceptionMapper.fromDioException(
        dioError(
          statusCode: 400,
          data: {'detail': 'Phone number is not valid'},
        ),
      );
      expect(result.message, 'Phone number is not valid');
    });

    test('parses FastAPI validation details into field messages', () {
      final result = ApiExceptionMapper.fromDioException(
        dioError(
          statusCode: 422,
          data: {
            'detail': [
              {
                'loc': ['body', 'phone'],
                'msg': 'String should match pattern',
                'type': 'string_pattern_mismatch',
              },
              {
                'loc': ['body', 'purpose'],
                'msg': 'Field required',
                'type': 'missing',
              },
            ],
          },
        ),
      );
      expect(
        result.message,
        'phone: String should match pattern\npurpose: Field required',
      );
    });

    test('falls back to a generic message when no detail is present', () {
      final result = ApiExceptionMapper.fromDioException(
        dioError(statusCode: 500, data: {'unexpected': true}),
      );
      expect(result.message, contains('HTTP 500'));
    });
  });

  group('FailureMapper', () {
    test('maps each ApiException family to the matching Failure', () {
      expect(
        FailureMapper.fromApiException(const UnauthorizedException()),
        isA<UnauthorizedFailure>(),
      );
      expect(
        FailureMapper.fromApiException(const ForbiddenException()),
        isA<ForbiddenFailure>(),
      );
      expect(
        FailureMapper.fromApiException(const NotFoundException()),
        isA<NotFoundFailure>(),
      );
      expect(
        FailureMapper.fromApiException(const ConflictException()),
        isA<ConflictFailure>(),
      );
      expect(
        FailureMapper.fromApiException(
          const ValidationException(message: 'bad'),
        ),
        isA<ValidationFailure>(),
      );
      expect(
        FailureMapper.fromApiException(const RateLimitException()),
        isA<RateLimitFailure>(),
      );
      expect(
        FailureMapper.fromApiException(const NetworkException()),
        isA<NetworkFailure>(),
      );
      expect(
        FailureMapper.fromApiException(const NetworkTimeoutException()),
        isA<NetworkTimeoutFailure>(),
      );
      expect(
        FailureMapper.fromApiException(const ServerException()),
        isA<ServerFailure>(),
      );
      expect(
        FailureMapper.fromApiException(const RequestCancelledException()),
        isA<CancelledFailure>(),
      );
    });

    test('falls back to UnexpectedFailure for unknown errors', () {
      expect(
        FailureMapper.fromException(StateError('oops')),
        isA<UnexpectedFailure>(),
      );
    });
  });
}
