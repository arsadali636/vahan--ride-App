import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/api/api_client.dart';
import 'package:doc_connect_app/core/constants/api_endpoints.dart';
import 'package:doc_connect_app/core/errors/exceptions.dart';
import 'package:doc_connect_app/features/doctor_network/data/datasources/doctor_network_remote_data_source.dart';
import 'package:doc_connect_app/features/doctor_network/data/models/doctor_search_query_model.dart';

/// Records outgoing calls and returns a canned body for every call.
class _RecordingApiClient extends ApiClient {
  _RecordingApiClient(this.canned)
    : super(Dio(BaseOptions(baseUrl: 'http://test')));

  final Map<String, dynamic> canned;
  final List<({String path, Map<String, dynamic>? query, bool requiresAuth})>
  calls = [];

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    calls.add((path: path, query: queryParameters, requiresAuth: requiresAuth));
    if (canned[path] is Function) {
      throw (canned[path] as Function)();
    }
    return canned[path];
  }
}

final _resultItem = {
  'id': '71f09e5f-c7be-4705-a2bf-2496ad69c124',
  'full_name': 'Bravo Target',
  'first_name': 'Bravo',
  'last_name': 'Target',
  'headline': 'Senior Consultant',
  'photo_file_id': null,
  'primary_specialization_id': 'Cardiology',
  'professional_location': {'city': 'Mumbai', 'state': 'Maharashtra'},
  'experience_years': 12.0,
  'open_to_opportunities': true,
  'verification_status': 'UNVERIFIED',
  'is_verified': false,
};

void main() {
  late _RecordingApiClient apiClient;
  late DoctorNetworkRemoteDataSource dataSource;

  setUp(() {
    apiClient = _RecordingApiClient({
      ApiEndpoints.doctorSearch: {
        'total': 1,
        'page': 1,
        'page_size': 20,
        'results': [_resultItem],
      },
    });
    dataSource = DoctorNetworkRemoteDataSourceImpl(apiClient: apiClient);
  });

  group('searchDoctors', () {
    test('hits the search path with mapped query parameters', () async {
      final response = await dataSource.searchDoctors(
        const DoctorSearchQueryModel(
          search: 'Ahmed',
          specialty: 'Cardiology',
          city: 'Mumbai',
          experienceMin: 5,
          openToOpportunities: true,
          page: 2,
          pageSize: 10,
        ),
      );

      final call = apiClient.calls.single;
      expect(call.path, ApiEndpoints.doctorSearch);
      expect(call.requiresAuth, isTrue);
      expect(call.query, {
        'search': 'Ahmed',
        'specialty': 'Cardiology',
        'city': 'Mumbai',
        'experience_min': 5,
        'open_to_opportunities': true,
        'page': 2,
        'page_size': 10,
      });

      final page = response.toEntity();
      expect(page.total, 1);
      expect(page.page, 1);
      expect(page.pageSize, 20);
      expect(page.items.single.id, '71f09e5f-c7be-4705-a2bf-2496ad69c124');
      expect(page.items.single.displayName, 'Bravo Target');
      expect(page.items.single.headline, 'Senior Consultant');
      expect(page.items.single.locationLabel, 'Mumbai, Maharashtra');
      expect(page.items.single.openToOpportunities, isTrue);
    });

    test('propagates the typed ApiException', () async {
      dataSource = DoctorNetworkRemoteDataSourceImpl(
        apiClient: _RecordingApiClient({
          ApiEndpoints.doctorSearch: () =>
              const ServerException(message: 'backend exploded'),
        }),
      );

      await expectLater(
        dataSource.searchDoctors(const DoctorSearchQueryModel()),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'backend exploded',
          ),
        ),
      );
    });
  });

  group('getDoctorProfile', () {
    test('hits the public profile path and parses the response', () async {
      final recorder = _RecordingApiClient({
        ApiEndpoints.doctorProfileById('doc-1'): {
          'id': 'doc-1',
          'full_name': 'Bravo Target',
          'first_name': 'Bravo',
          'last_name': 'Target',
          'about': 'Heart surgeon.',
          'clinical_interests': ['Cardiology'],
          'verification_status': 'VERIFIED',
          'is_verified': true,
          'experience_years': 12.0,
        },
      });
      dataSource = DoctorNetworkRemoteDataSourceImpl(apiClient: recorder);

      final profile = await dataSource.getDoctorProfile('doc-1');

      final call = recorder.calls.single;
      expect(call.path, ApiEndpoints.doctorProfileById('doc-1'));
      expect(call.requiresAuth, isTrue);

      final entity = profile.toEntity();
      expect(entity.id, 'doc-1');
      expect(entity.about, 'Heart surgeon.');
      expect(entity.clinicalInterests, ['Cardiology']);
      expect(entity.verificationStatus.name, 'verified');
      expect(entity.isVerified, isTrue);
    });

    test('propagates the typed ApiException', () async {
      dataSource = DoctorNetworkRemoteDataSourceImpl(
        apiClient: _RecordingApiClient({
          ApiEndpoints.doctorProfileById('missing'): () =>
              const NotFoundException(message: 'Doctor not found'),
        }),
      );

      await expectLater(
        dataSource.getDoctorProfile('missing'),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            'Doctor not found',
          ),
        ),
      );
    });
  });
}
