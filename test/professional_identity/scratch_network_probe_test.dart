import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/api/api_client.dart';
import 'package:doc_connect_app/core/network/dio_factory.dart';
import 'package:doc_connect_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:doc_connect_app/features/auth/data/models/register_request_model.dart';

import '../helpers/fake_session_service.dart';

const bool _runLive =
    bool.fromEnvironment('LIVE_PROBE') || bool.fromEnvironment('LIVE_SMOKE');

/// Live network diagnostic probe against the running backend.
///
/// Disabled by default in automated test runs to keep tests deterministic and
/// offline-capable. Run explicitly with:
///   flutter test test/professional_identity/scratch_network_probe_test.dart \
///     --dart-define=LIVE_PROBE=true
void main() {
  final rand = Random();

  setUpAll(() {
    HttpOverrides.global = null;
  });

  Dio buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'http://3.111.58.158',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
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
    'probe search result item shape via a second doctor',
    skip: !_runLive
        ? 'Skipped: live network probe requires --dart-define=LIVE_PROBE=true'
        : false,
    () async {
      final dataSource = AuthRemoteDataSourceImpl(
        apiClient: ApiClient(buildDio()),
      );

      // Doctor A — the searcher.
      final a = await dataSource.register(
        RegisterRequestModel(
          firstName: 'Alpha',
          lastName: 'Searcher',
          phone: phone(),
          password: 'probe12345',
          email: 'alpha${phone()}@example.com',
        ),
      );
      final sessionA = FakeSessionService();
      await sessionA.saveSession(
        tokens: a.toEntity().tokens,
        userId: a.userId,
        userRole: a.userType,
      );
      final dioA = DioFactory.create(
        baseUrl: 'http://65.1.134.1',
        sessionService: sessionA,
        refreshHandler: (t) => dataSource.refreshToken(t),
        enableLogging: false,
      );

      // Doctor B — the search target.
      final b = await dataSource.register(
        RegisterRequestModel(
          firstName: 'Bravo',
          lastName: 'Target',
          phone: phone(),
          password: 'probe12345',
          email: 'bravo${phone()}@example.com',
        ),
      );

      // Search by name with A's token.
      try {
        final searchRes = await dioA.get(
          '/api/v1/doctors/search/',
          queryParameters: const {
            'search': 'Bravo',
            'page': 1,
            'page_size': 20,
          },
        );
        // ignore: avoid_print
        print('SEARCH_RESULT_RAW=${searchRes.toString()}');
      } catch (e) {
        // ignore: avoid_print
        print('SEARCH_RESULT_ERROR=$e');
      }

      // Public profile of B.
      try {
        final publicRes = await dioA.get(
          '/api/v1/doctors/profile/${b.userId}/',
        );
        // ignore: avoid_print
        print('PUBLIC_BY_USER_ID_RAW=${publicRes.toString()}');
      } catch (e) {
        // ignore: avoid_print
        print('PUBLIC_BY_USER_ID_ERROR=$e');
      }

      // Profile-id lookup: fetch B's profile id via B's own session.
      final sessionB = FakeSessionService();
      await sessionB.saveSession(
        tokens: b.toEntity().tokens,
        userId: b.userId,
        userRole: b.userType,
      );
      final dioB = DioFactory.create(
        baseUrl: 'http://65.1.134.1',
        sessionService: sessionB,
        refreshHandler: (t) => dataSource.refreshToken(t),
        enableLogging: false,
      );
      try {
        final me = await dioB.get('/api/v1/doctors/profile/me/');
        final id = (me.data as Map)['id'];
        // ignore: avoid_print
        print('B_PROFILE_ID=$id');
        final publicRes = await dioA.get('/api/v1/doctors/profile/$id/');
        // ignore: avoid_print
        print('PUBLIC_BY_PROFILE_ID_RAW=${publicRes.toString()}');
      } catch (e) {
        // ignore: avoid_print
        print('PUBLIC_BY_PROFILE_ID_ERROR=$e');
      }

      // Unfiltered search to see what is discoverable.
      try {
        final all = await dioA.get('/api/v1/doctors/search/');
        // ignore: avoid_print
        print('SEARCH_ALL_RAW=${all.toString()}');
      } catch (e) {
        // ignore: avoid_print
        print('SEARCH_ALL_ERROR=$e');
      }

      // Filtered combos to probe the item shape / backend filter behavior.
      for (final qp in <Map<String, dynamic>>[
        const {'page_size': 100},
        const {'specialty': 'Cardiology'},
        const {'city': 'Mumbai'},
        const {'open_to_opportunities': 'true'},
        const {'experience_min': 5},
        const {'search': 'Bravo Target'},
        const {'search': 'a'},
      ]) {
        try {
          final res = await dioA.get(
            '/api/v1/doctors/search/',
            queryParameters: qp,
          );
          // ignore: avoid_print
          print('SEARCH_QP=$qp RAW=${res.toString()}');
        } catch (e) {
          // ignore: avoid_print
          print('SEARCH_QP=$qp ERROR=$e');
        }
      }
    },
  );
}
