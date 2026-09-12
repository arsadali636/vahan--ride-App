import 'package:dio/dio.dart';

import '../../errors/error_mapper.dart';
import '../../errors/exceptions.dart';

/// Central API error interceptor.
///
/// Converts raw [DioException]s into typed [ApiException]s (attached to the
/// exception's `error` field) before they reach the call site, so the rest of
/// the app never deals with transport details. Refresh logic still runs
/// because this interceptor preserves the original response/request.
class ApiErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = ApiExceptionMapper.fromDioException(err);
    final wrapped = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
      stackTrace: err.stackTrace,
      message: apiException.message,
    );
    handler.next(wrapped);
  }
}
