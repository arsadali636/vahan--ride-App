import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/enums/user_role.dart';
import 'package:doc_connect_app/features/auth/data/models/otp_verify_request_model.dart';
import 'package:doc_connect_app/features/auth/data/models/password_login_request_model.dart';
import 'package:doc_connect_app/features/auth/data/models/register_request_model.dart';
import 'package:doc_connect_app/features/auth/data/models/register_response_model.dart';
import 'package:doc_connect_app/features/auth/data/models/token_response_model.dart';
import 'package:doc_connect_app/features/auth/domain/entities/otp_purpose.dart';

void main() {
  group('RegisterRequestModel', () {
    test('serializes a doctor registration without email', () {
      const request = RegisterRequestModel(
        firstName: 'Ada',
        lastName: 'Lovelace',
        phone: '9876543210',
        password: 'secret123',
      );

      expect(request.toJson(), {
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'phone': '9876543210',
        'password': 'secret123',
        'user_type': 'DOCTOR',
      });
    });

    test('serializes a hospital admin registration with email', () {
      const request = RegisterRequestModel(
        firstName: 'Grace',
        lastName: 'Hopper',
        phone: '9123456789',
        password: 'secret123',
        userType: UserRole.hospital,
        email: 'grace@hospital.example',
      );

      expect(request.toJson()['user_type'], 'HOSPITAL_ADMIN');
      expect(request.toJson()['email'], 'grace@hospital.example');
    });

    test('matches the exact payload of the live backend curl sample', () {
      const request = RegisterRequestModel(
        firstName: 'Test',
        lastName: 'Doctor',
        phone: '9876543210',
        password: '12345678',
        userType: UserRole.doctor,
        email: 'testdoctor@gmail.com',
      );

      expect(request.toJson(), {
        'first_name': 'Test',
        'last_name': 'Doctor',
        'phone': '9876543210',
        'password': '12345678',
        'user_type': 'DOCTOR',
        'email': 'testdoctor@gmail.com',
      });
    });
  });

  group('RegisterResponseModel', () {
    test('parses the backend body and maps to an AuthSession', () {
      final model = RegisterResponseModel.fromJson({
        'access_token': 'at-1',
        'refresh_token': 'rt-1',
        'token_type': 'bearer',
        'user_id': 'u-1',
        'user_type': 'DOCTOR',
        'profile_created': true,
      });

      expect(model.userId, 'u-1');
      expect(model.userType, UserRole.doctor);
      expect(model.profileCreated, isTrue);

      final entity = model.toEntity();
      expect(entity.tokens.accessToken, 'at-1');
      expect(entity.tokens.refreshToken, 'rt-1');
      expect(entity.userId, 'u-1');
      expect(entity.userRole, UserRole.doctor);
      expect(entity.profileCreated, isTrue);
    });

    test('maps hospital HR wire value to the enum', () {
      final model = RegisterResponseModel.fromJson({
        'access_token': 'at-1',
        'refresh_token': 'rt-1',
        'user_id': 'u-2',
        'user_type': 'HOSPITAL_HR',
        'profile_created': false,
      });
      expect(model.userType, UserRole.hospitalHr);
    });

    test('treats an unknown user_type as doctor', () {
      final model = RegisterResponseModel.fromJson({
        'access_token': 'at-1',
        'refresh_token': 'rt-1',
        'user_id': 'u-3',
        'user_type': 'ALIEN',
        'profile_created': false,
      });
      expect(model.userType, UserRole.doctor);
    });

    test('parses the verbatim live backend registration response', () {
      final model = RegisterResponseModel.fromJson({
        'access_token':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzg2MjQ0NjA0LCJpYXQiOjE3ODYyNDEwMDQsImp0aSI6IjNiMzE2ZDVjMDFkMDQyNTI5NTZkYWE5Y2FmMDU0NWVjIiwidXNlcl9pZCI6Ijg4NGVlYTUyLWI5NzctNGIxZS1hNTQ4LTU0MTY3Nzk4YzA0NSJ9.fKj5l-jHb5rruUbH_dR7HzGDnFDk87Jewm7Pv9Jpi1Q',
        'refresh_token':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4ODgzMzAwNCwiaWF0IjoxNzg2MjQxMDA0LCJqdGkiOiI3YzkzYzU2ZmJlYmE0ODVlOTdhYjJmOWQwMjljYzAzNiIsInVzZXJfaWQiOiI4ODRlZWE1Mi1iOTc3LTRiMWUtYTU0OC01NDE2Nzc5OGMwNDUifQ.Vz8j0PwzN1iQsUDdISJhy58pbIDRHL6_5ExZRTLgfcw',
        'token_type': 'bearer',
        'user_id': '884eea52-b977-4b1e-a548-54167798c045',
        'user_type': 'DOCTOR',
        'profile_created': true,
      });

      expect(model.accessToken, startsWith('eyJ'));
      expect(model.refreshToken, startsWith('eyJ'));
      expect(model.tokenType, 'bearer');
      expect(model.userId, '884eea52-b977-4b1e-a548-54167798c045');
      expect(model.userType, UserRole.doctor);
      expect(model.profileCreated, isTrue);

      final entity = model.toEntity();
      expect(entity.userId, '884eea52-b977-4b1e-a548-54167798c045');
      expect(entity.userRole, UserRole.doctor);
      expect(entity.profileCreated, isTrue);
      expect(entity.tokens.accessToken, model.accessToken);
      expect(entity.tokens.refreshToken, model.refreshToken);
    });
  });

  group('PasswordLoginRequestModel', () {
    test('serializes without device_id when null', () {
      const request = PasswordLoginRequestModel(
        phone: '9876543210',
        password: 'pass',
      );
      expect(request.toJson(), {'phone': '9876543210', 'password': 'pass'});
    });

    test('serializes device_id when provided', () {
      const request = PasswordLoginRequestModel(
        phone: '9876543210',
        password: 'pass',
        deviceId: 'd-1',
      );
      expect(request.toJson()['device_id'], 'd-1');
    });
  });

  group('TokenResponseModel', () {
    test('parses tokens with a default bearer type', () {
      final model = TokenResponseModel.fromJson({
        'access_token': 'at-1',
        'refresh_token': 'rt-1',
      });

      expect(model.tokenType, 'bearer');
      expect(model.toTokenPair().accessToken, 'at-1');
      expect(model.toTokenPair().refreshToken, 'rt-1');
    });

    test('parses the explicit token_type', () {
      final model = TokenResponseModel.fromJson({
        'access_token': 'at-1',
        'refresh_token': 'rt-1',
        'token_type': 'Bearer',
      });
      expect(model.tokenType, 'Bearer');
    });
  });

  group('OtpVerifyRequestModel', () {
    test('serializes defaults for a doctor login OTP', () {
      const request = OtpVerifyRequestModel(phone: '9876543210', otp: '123456');

      expect(request.toJson(), {
        'phone': '9876543210',
        'otp': '123456',
        'purpose': 'LOGIN',
        'user_type': 'DOCTOR',
      });
    });

    test('serializes a register OTP for a hospital admin with device id', () {
      const request = OtpVerifyRequestModel(
        phone: '9876543210',
        otp: '654321',
        purpose: OtpPurpose.register,
        userType: UserRole.hospital,
        deviceId: 'd-1',
      );

      expect(request.toJson(), {
        'phone': '9876543210',
        'otp': '654321',
        'purpose': 'REGISTER',
        'user_type': 'HOSPITAL_ADMIN',
        'device_id': 'd-1',
      });
    });
  });
}
