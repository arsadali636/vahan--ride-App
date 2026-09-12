import 'package:flutter_test/flutter_test.dart';
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
import 'package:doc_connect_app/features/auth/domain/usecases/send_otp_usecase.dart';

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  SendOtpRequestModel? lastRequest;
  SendOtpResponseModel? result;
  ApiException? errorToThrow;

  @override
  Future<SendOtpResponseModel> sendOtp(SendOtpRequestModel request) async {
    lastRequest = request;
    if (errorToThrow != null) throw errorToThrow!;
    return result!;
  }

  @override
  Future<AuthTokenPair> refreshToken(String refreshToken) async {
    throw UnimplementedError();
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokenPair> passwordLogin(PasswordLoginRequestModel request) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthTokenPair> verifyOtp(OtpVerifyRequestModel request) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}

void main() {
  group('SendOtpRequestModel', () {
    test('serializes to the backend body', () {
      const request = SendOtpRequestModel(
        phone: '9876543210',
        purpose: OtpPurpose.register,
      );
      expect(request.toJson(), {
        'phone': '9876543210',
        'purpose': 'REGISTER',
      });
    });
  });

  group('SendOtpResponseModel', () {
    test('parses the dev response including otp', () {
      final model = SendOtpResponseModel.fromJson({
        'success': true,
        'message': 'OTP generated (SMS disabled in dev mode)',
        'expires_in': 300,
        'otp': '335345',
      });
      expect(model.success, isTrue);
      expect(model.message, 'OTP generated (SMS disabled in dev mode)');
      expect(model.expiresIn, 300);
      expect(model.otp, '335345');
      expect(model.toEntity().otp, '335345');
    });

    test('treats otp as null when absent (production)', () {
      final model = SendOtpResponseModel.fromJson({
        'success': true,
        'message': 'OTP sent via SMS',
        'expires_in': 300,
      });
      expect(model.otp, isNull);
    });
  });

  group('SendOtpUseCase through repository', () {
    test('sends phone and purpose and returns result', () async {
      final dataSource = _FakeAuthRemoteDataSource()
        ..result = const SendOtpResponseModel(
          success: true,
          message: 'OTP generated',
          expiresIn: 300,
          otp: '335345',
        );
      final repo = AuthRepositoryImpl(remoteDataSource: dataSource);
      final useCase = SendOtpUseCase(repo);

      final result = await useCase(
        const SendOtpParams(phone: '9876543210', purpose: OtpPurpose.login),
      );

      expect(dataSource.lastRequest?.phone, '9876543210');
      expect(dataSource.lastRequest?.purpose, OtpPurpose.login);
      expect(result.success, isTrue);
      expect(result.expiresIn, 300);
      expect(result.otp, '335345');
    });

    test('maps a backend ApiException to a Failure', () async {
      final dataSource = _FakeAuthRemoteDataSource()
        ..errorToThrow = BadRequestException(message: 'Invalid phone');
      final repo = AuthRepositoryImpl(remoteDataSource: dataSource);
      final useCase = SendOtpUseCase(repo);

      await expectLater(
        useCase(
          const SendOtpParams(phone: '9876543210', purpose: OtpPurpose.login),
        ),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });
}
