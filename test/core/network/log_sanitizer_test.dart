import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/network/logging/log_sanitizer.dart';

void main() {
  group('LogSanitizer.sanitizeJson', () {
    test('masks top-level sensitive keys', () {
      final sanitized = LogSanitizer.sanitizeJson(const {
        'phone': '+911234567890',
        'password': 'hunter2',
        'otp': '7777',
        'access_token': 'a.b.c',
        'refresh_token': 'r.t.u',
        'pin': '4321',
        'secret': 's3cr3t',
      });

      expect(sanitized, contains('"password":"********"'));
      expect(sanitized, contains('"otp":"********"'));
      expect(sanitized, contains('"access_token":"********"'));
      expect(sanitized, contains('"refresh_token":"********"'));
      expect(sanitized, contains('"pin":"********"'));
      expect(sanitized, contains('"secret":"********"'));
      expect(sanitized, contains('"phone":"+911234567890"'));
      expect(sanitized, isNot(contains('hunter2')));
      expect(sanitized, isNot(contains('7777')));
      expect(sanitized, isNot(contains('a.b.c')));
    });

    test('masks nested sensitive keys', () {
      final sanitized = LogSanitizer.sanitizeJson(const {
        'user': {
          'profile': {
            'email': 'doctor@example.com',
            'medical_document': 'file.pdf',
          },
        },
        'data': {'token': 'jwt-value', 'private_message': 'hello'},
      });

      expect(sanitized, contains('"email":"doctor@example.com"'));
      expect(sanitized, contains('"medical_document":"********"'));
      expect(sanitized, contains('"token":"********"'));
      expect(sanitized, contains('"private_message":"********"'));
      expect(sanitized, isNot(contains('jwt-value')));
      expect(sanitized, isNot(contains('hello')));
    });

    test('masks sensitive keys inside lists', () {
      final sanitized = LogSanitizer.sanitizeJson(const [
        {'name': 'a', 'password': 'x'},
        {'name': 'b', 'password': 'y'},
      ]);

      expect(sanitized, contains('"name":"a"'));
      expect(sanitized, isNot(contains('"password":"x"')));
      expect(sanitized, isNot(contains('"password":"y"')));
    });

    test('handles non-JSON-encodable values without throwing', () {
      final sanitized = LogSanitizer.sanitizeJson(Object());
      expect(sanitized, isA<String>());
    });
  });

  group('LogSanitizer.truncate', () {
    test('returns short strings unchanged', () {
      expect(LogSanitizer.truncate('short', maxLength: 100), 'short');
    });

    test('truncates long strings with a marker', () {
      final value = 'x' * 100;
      final truncated = LogSanitizer.truncate(value, maxLength: 10);
      expect(truncated.length, lessThan(value.length));
      expect(truncated, contains('[truncated 90 chars]'));
    });
  });

  group('LogSanitizer.maskHeaderValue', () {
    test('masks authorization preserving the Bearer scheme', () {
      expect(
        LogSanitizer.maskHeaderValue(
          'Authorization',
          'Bearer real-token-value',
        ),
        'Bearer ********',
      );
    });

    test('masks other sensitive headers entirely', () {
      expect(LogSanitizer.maskHeaderValue('x-api-key', 'abc123'), '********');
      expect(
        LogSanitizer.maskHeaderValue('Cookie', 'sessionid=abc; csrftoken=def'),
        '********',
      );
      expect(
        LogSanitizer.maskHeaderValue('set-cookie', 'sessionid=abc; Path=/'),
        '********',
      );
    });

    test('leaves safe headers unchanged', () {
      expect(
        LogSanitizer.maskHeaderValue('content-type', 'application/json'),
        'application/json',
      );
    });
  });

  group('LogSanitizer.sanitizeHeaders', () {
    test('masks sensitive headers while preserving non-sensitive ones', () {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer super-secret-jwt',
        'Cookie': 'sessionid=secret-session; csrftoken=secret-csrf',
        'Set-Cookie': 'sessionid=secret-session; Path=/',
      };
      final sanitized = LogSanitizer.sanitizeHeaders(headers);

      expect(sanitized, contains('Content-Type: application/json'));
      expect(sanitized, contains('Authorization: Bearer ********'));
      expect(sanitized, contains('Cookie: ********'));
      expect(sanitized, contains('Set-Cookie: ********'));
      expect(sanitized, isNot(contains('super-secret-jwt')));
      expect(sanitized, isNot(contains('secret-session')));
      expect(sanitized, isNot(contains('secret-csrf')));
    });
  });

  group('LogSanitizer.isSensitiveKey', () {
    test('matches keys case-insensitively', () {
      expect(LogSanitizer.isSensitiveKey('Password'), isTrue);
      expect(LogSanitizer.isSensitiveKey('ACCESS_TOKEN'), isTrue);
      expect(LogSanitizer.isSensitiveKey('access_token'), isTrue);
      expect(LogSanitizer.isSensitiveKey('medical_document'), isTrue);
      expect(LogSanitizer.isSensitiveKey('cookie'), isTrue);
      expect(LogSanitizer.isSensitiveKey('sessionid'), isTrue);
      expect(LogSanitizer.isSensitiveKey('csrftoken'), isTrue);
      expect(LogSanitizer.isSensitiveKey('otp'), isTrue);
      expect(LogSanitizer.isSensitiveKey('name'), isFalse);
    });
  });
}
