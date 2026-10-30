import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/api/api_client.dart';
import 'package:doc_connect_app/core/enums/user_role.dart';
import 'package:doc_connect_app/core/network/dio_factory.dart';
import 'package:doc_connect_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:doc_connect_app/features/auth/data/models/password_login_request_model.dart';
import 'package:doc_connect_app/features/auth/data/models/register_request_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/datasources/doctor_profile_remote_data_source.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_profile_update_model.dart';

import '../helpers/fake_session_service.dart';

const bool _runLive = bool.fromEnvironment('LIVE_SMOKE');

/// End-to-end smoke test against the real backend.
///
/// Disabled by default; run explicitly with:
///   flutter test test/auth/live_smoke_test.dart \
///     --dart-define=LIVE_SMOKE=true
/// Creates one throwaway account (random phone) on each run and exercises the
/// auth + doctor profile flows through the app's real DTOs and Dio stack.
void main() {
  final rand = Random();

  setUpAll(() {
    HttpOverrides.global = null;
  });

  Dio buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'http://3.111.58.158',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  String phone() => '9${List.generate(9, (_) => rand.nextInt(10)).join()}';

  test(
    'registers, logs in, refreshes and reads/updates the profile',
    skip: !_runLive,
    () async {
      final dataSource = AuthRemoteDataSourceImpl(
        apiClient: ApiClient(buildDio()),
      );
      final phoneNumber = phone();

      final registered = await dataSource.register(
        RegisterRequestModel(
          firstName: 'Smoke',
          lastName: 'Doctor',
          phone: phoneNumber,
          password: 'smoke12345',
          email: 'smoke$phoneNumber@example.com',
        ),
      );
      expect(registered.userId, isNotEmpty);
      expect(registered.accessToken, isNotEmpty);
      expect(registered.refreshToken, isNotEmpty);
      expect(registered.userType, UserRole.doctor);
      expect(registered.profileCreated, isTrue);

      final login = await dataSource.passwordLogin(
        PasswordLoginRequestModel(phone: phoneNumber, password: 'smoke12345'),
      );
      expect(login.accessToken, isNotEmpty);
      expect(login.refreshToken, isNotEmpty);

      final refreshed = await dataSource.refreshToken(login.refreshToken);
      expect(refreshed.accessToken, isNotEmpty);
      expect(refreshed.accessToken, isNot(login.accessToken));
      expect(refreshed.refreshToken, isNotEmpty);

      final sessionService = FakeSessionService();
      await sessionService.saveSession(
        tokens: refreshed,
        userId: registered.userId,
        userRole: registered.userType,
      );

      final authenticatedDio = DioFactory.create(
        baseUrl: 'http://65.1.134.1',
        sessionService: sessionService,
        refreshHandler: (refreshToken) => dataSource.refreshToken(refreshToken),
        enableLogging: false,
      );
      final profileDataSource = DoctorProfileRemoteDataSourceImpl(
        apiClient: ApiClient(authenticatedDio),
      );

      final profile = await profileDataSource.getMyProfile();
      expect(profile.id, isNotEmpty);
      expect(profile.userId, registered.userId);
      expect(profile.firstName, 'Smoke');

      final updated = await profileDataSource.update(
        const DoctorProfileUpdateModel(headline: 'Smoke Test Headline'),
      );
      expect(updated.headline, 'Smoke Test Headline');
      expect(updated.firstName, 'Smoke');
    },
  );
}
