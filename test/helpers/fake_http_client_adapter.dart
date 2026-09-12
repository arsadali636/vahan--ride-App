import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Configurable in-memory [HttpClientAdapter] for network-layer tests.
///
/// Captures every request so tests can assert headers/extra, returns a canned
/// [ResponseBody], or throws a canned [DioException] to simulate transport
/// failures (timeouts, connection errors).
class RecordingHttpClientAdapter implements HttpClientAdapter {
  RecordingHttpClientAdapter({
    this.statusCode = 200,
    this.body = '{}',
    this.headers = const {},
    this.throwError,
  });

  int statusCode;
  String body;
  Map<String, List<String>> headers;
  DioException? throwError;

  final List<RequestOptions> captured = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured.add(options);
    if (throwError != null) throw throwError!;
    final responseHeaders = headers.isEmpty
        ? {Headers.contentTypeHeader: ['application/json']}
        : headers;
    return ResponseBody.fromString(body, statusCode, headers: responseHeaders);
  }

  @override
  void close({bool force = false}) {}
}
