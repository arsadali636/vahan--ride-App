import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/enums/user_role.dart';
import 'package:doc_connect_app/core/errors/exceptions.dart';
import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/core/storage/session_service.dart';
import 'package:doc_connect_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:doc_connect_app/features/auth/data/models/otp_verify_request_model.dart';
import 'package:doc_connect_app/features/auth/data/models/password_login_request_model.dart';
import 'package:doc_connect_app/features/auth/data/models/register_request_model.dart';
import 'package:doc_connect_app/features/auth/data/models/register_response_model.dart';
import 'package:doc_connect_app/features/auth/data/models/send_otp_request_model.dart';
import 'package:doc_connect_app/features/auth/data/models/send_otp_response_model.dart';
import 'package:doc_connect_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:doc_connect_app/features/auth/domain/entities/otp_purpose.dart';

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  RegisterRequestModel? lastRegister;
  PasswordLoginRequestModel? lastLogin;
  OtpVerifyRequestModel? lastOtpVerify;
  RegisterResponseModel? registerResult;
  AuthTokenPair? loginResult;
  ApiException? errorToThrow;
  bool logoutCalled = false;
  String? lastRefreshedToken;
  AuthTokenPair? refreshResult;

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    lastRegister = request;
    if (errorToThrow != null) throw errorToThrow!;
    return registerResult!;
  }

  @override
  Future<AuthTokenPair> passwordLogin(PasswordLoginRequestModel request) async {
    lastLogin = request;
    if (errorToThrow != null) throw errorToThrow!;
    return loginResult!;
  }

  @override
  Future<AuthTokenPair> verifyOtp(OtpVerifyRequestModel request) async {
    lastOtpVerify = request;
    if (errorToThrow != null) throw errorToThrow!;
    return loginResult!;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokenPair> refreshToken(String refreshToken) async {
    lastRefreshedToken = refreshToken;
    if (errorToThrow != null) throw errorToThrow!;
    return refreshResult!;
  }
}

void main() {
  late _FakeAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: dataSource);
  });

  group('register', () {
    setUp(() {
      dataSource.registerResult = const RegisterResponseModel(
        accessToken: 'at-1',
        refreshToken: 'rt-1',
        userId: 'u-1',
        userType: UserRole.hospital,
        profileCreated: true,
      );
    });

    test('forwards params and maps the response to an AuthSession', () async {
      final session = await repository.register(
        firstName: 'Ada',
        lastName: 'Lovelace',
        phone: '9876543210',
        password: 'secret123',
        userType: UserRole.hospital,
        email: 'ada@example.com',
      );

      expect(dataSource.lastRegister?.phone, '9876543210');
      expect(dataSource.lastRegister?.userType, UserRole.hospital);
      expect(dataSource.lastRegister?.email, 'ada@example.com');
      expect(session.tokens.accessToken, 'at-1');
      expect(session.userId, 'u-1');
      expect(session.userRole, UserRole.hospital);
      expect(session.profileCreated, isTrue);
    });

    test('maps a backend ApiException to a Failure', () async {
      dataSource.errorToThrow =
          ValidationException(message: 'phone: Invalid value');

      await expectLater(
        repository.register(
          firstName: 'Ada',
          lastName: 'Lovelace',
          phone: '999',
          password: 'x',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('passwordLogin', () {
    setUp(() {
      dataSource.loginResult = const AuthTokenPair(
        accessToken: 'at-1',
        refreshToken: 'rt-1',
      );
    });

    test('returns an AuthSession with tokens only', () async {
      final session = await repository.passwordLogin(
        phone: '9876543210',
        password: 'pass',
      );

      expect(dataSource.lastLogin?.phone, '9876543210');
      expect(dataSource.lastLogin?.password, 'pass');
      expect(session.tokens.accessToken, 'at-1');
      expect(session.userId, isNull);
      expect(session.userRole, isNull);
    });

    test('maps a 401 to UnauthorizedFailure', () async {
      dataSource.errorToThrow =
          UnauthorizedException(message: 'Invalid credentials');

      await expectLater(
        repository.passwordLogin(phone: '9876543210', password: 'wrong'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });

  group('verifyOtp', () {
    setUp(() {
      dataSource.loginResult = const AuthTokenPair(
        accessToken: 'at-2',
        refreshToken: 'rt-2',
      );
    });

    test('forwards purpose and user type', () async {
      final session = await repository.verifyOtp(
        phone: '9876543210',
        otp: '123456',
        purpose: OtpPurpose.register,
        userType: UserRole.hospital,
      );

      expect(dataSource.lastOtpVerify?.purpose, OtpPurpose.register);
      expect(dataSource.lastOtpVerify?.userType, UserRole.hospital);
      expect(session.tokens.accessToken, 'at-2');
    });
  });

  group('refreshToken', () {
    setUp(() {
      dataSource.refreshResult = const AuthTokenPair(
        accessToken: 'at-9',
        refreshToken: 'rt-9',
      );
    });

    test('forwards the refresh token and maps the response', () async {
      final pair = await repository.refreshToken('old-refresh');

      expect(dataSource.lastRefreshedToken, 'old-refresh');
      expect(pair.accessToken, 'at-9');
      expect(pair.refreshToken, 'rt-9');
    });

    test('maps a 401 to UnauthorizedFailure', () async {
      dataSource.errorToThrow = UnauthorizedException(message: 'expired');

      await expectLater(
        repository.refreshToken('old-refresh'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });

  group('logout', () {
    test('calls the remote endpoint', () async {
      await repository.logout();
      expect(dataSource.logoutCalled, isTrue);
    });

    test('swallows remote failures so the session can still be cleared',
        () async {
      dataSource.errorToThrow = UnauthorizedException(message: 'expired');

      await expectLater(repository.logout(), completes);
      expect(dataSource.logoutCalled, isTrue);
    });
  });
}
