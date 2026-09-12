import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/error_mapper.dart';
import '../errors/exceptions.dart';

/// Thin, Dio-backed HTTP client.
///
/// This is the single choke point for every backend call: no widget, bloc or
/// repository talks to Dio directly. Raw [DioException]s are converted here
/// into typed [ApiException]s (already attached by the error interceptor).
///
/// [requiresAuth] defaults to `true` so every request is authenticated unless
/// the RemoteDataSource explicitly opts out for an endpoint the OpenAPI
/// contract defines as public (e.g. `send-otp`, `login`).
class ApiClient {
  ApiClient(this._dio) {
    if (_dio.options.baseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is not configured. Run with '
        '--dart-define=API_BASE_URL=https://<host>',
      );
    }
  }

  final Dio _dio;

  Dio get dio => _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: _authOptions(options, requiresAuth),
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _authOptions(options, requiresAuth),
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _authOptions(options, requiresAuth),
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _authOptions(options, requiresAuth),
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _authOptions(options, requiresAuth),
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  /// Marks the request as public when [requiresAuth] is false by tagging
  /// `ApiConstants.requiresAuthExtraKey` on the [Options.extra]. [AuthInterceptor]
  /// reads this flag and skips the access token. Existing caller-provided
  /// options are preserved.
  Options _authOptions(Options? options, bool requiresAuth) {
    if (requiresAuth) return options ?? Options();
    return (options ?? Options()).copyWith(
      extra: {
        ...?options?.extra,
        ApiConstants.requiresAuthExtraKey: false,
      },
    );
  }

  /// Prefers the typed [ApiException] attached by [ApiErrorInterceptor];
  /// falls back to mapping here as a safety net.
  ApiException _unwrap(DioException error) {
    if (error.error is ApiException) {
      return error.error! as ApiException;
    }
    return ApiExceptionMapper.fromDioException(error);
  }
}
