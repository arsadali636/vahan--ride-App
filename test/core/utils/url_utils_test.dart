import 'package:flutter_test/flutter_test.dart';
import 'package:doc_connect_app/app/app_config.dart';
import 'package:doc_connect_app/app/environment_config.dart';
import 'package:doc_connect_app/core/utils/url_utils.dart';

void main() {
  setUpAll(() {
    AppConfig.initialize(
      environmentConfig: const EnvironmentConfig.development(
        apiBaseUrl: 'http://3.111.58.158',
        apiBasePath: '/api/v1',
      ),
    );
  });

  group('UrlUtils.resolveUrl', () {
    test('returns null for null, empty or whitespace input', () {
      expect(UrlUtils.resolveUrl(null), isNull);
      expect(UrlUtils.resolveUrl(''), isNull);
      expect(UrlUtils.resolveUrl('   '), isNull);
    });

    test('returns absolute HTTP and HTTPS URLs unchanged', () {
      expect(
        UrlUtils.resolveUrl('http://example.com/avatar.jpg'),
        'http://example.com/avatar.jpg',
      );
      expect(
        UrlUtils.resolveUrl('https://example.com/photo.png'),
        'https://example.com/photo.png',
      );
    });

    test(
      'resolves relative paths against API origin without duplicating path prefix',
      () {
        expect(
          UrlUtils.resolveUrl('/media/posts/image.jpg'),
          'http://3.111.58.158/media/posts/image.jpg',
        );
        expect(
          UrlUtils.resolveUrl('media/posts/image.jpg'),
          'http://3.111.58.158/media/posts/image.jpg',
        );
      },
    );
  });
}
