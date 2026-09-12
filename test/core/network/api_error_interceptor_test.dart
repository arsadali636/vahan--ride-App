import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/network/interceptors/api_error_interceptor.dart';
import 'package:doc_connect_app/core/errors/exceptions.dart';

import '../../helpers/fake_http_client_adapter.dart';

void main() {
  late RecordingHttpClientAdapter adapter;
  late Dio dio;

  setUp(() {
    adapter = RecordingHttpClientAdapter(
      statusCode: 404,
      body: '{"detail":"doctor not found"}',
    );
    dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(ApiErrorInterceptor());
  });

  test('attaches a typed ApiException to the DioException', () async {
    try {
      await dio.get('/doctors/999');
      fail('expected a DioException');
    } on DioException catch (e) {
      expect(e.error, isA<NotFoundException>());
      expect((e.error as NotFoundException).message, 'doctor not found');
      expect(e.response?.statusCode, 404);
    }
  });

  test('preserves the original response and status code', () async {
    try {
      await dio.get('/doctors/999');
      fail('expected a DioException');
    } on DioException catch (e) {
      expect(e.response?.statusCode, 404);
      expect(e.response?.data, {'detail': 'doctor not found'});
    }
  });

  test('maps 422 validation responses via the FastAPI detail shape',
      () async {
    adapter
      ..statusCode = 422
      ..body =
          '{"detail":[{"loc":["body","specialization_id"],"msg":"Field required","type":"missing"}]}';

    try {
      await dio.get('/doctors');
      fail('expected a DioException');
    } on DioException catch (e) {
      expect(e.error, isA<ValidationException>());
      expect(
        (e.error as ValidationException).message,
        'specialization_id: Field required',
      );
    }
  });
}
