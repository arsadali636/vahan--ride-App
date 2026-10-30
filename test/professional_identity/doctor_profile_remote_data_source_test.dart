import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/api/api_client.dart';
import 'package:doc_connect_app/core/constants/api_endpoints.dart';
import 'package:doc_connect_app/features/professional_identity/data/datasources/doctor_profile_remote_data_source.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_experience_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_profile_create_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_profile_update_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_qualification_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_registration_model.dart';

/// Records outgoing calls and returns a canned body for every call.
class _RecordingApiClient extends ApiClient {
  _RecordingApiClient(this.canned)
    : super(Dio(BaseOptions(baseUrl: 'http://test')));

  final Map<String, dynamic> canned;
  final List<({String path, Object? data, bool requiresAuth})> calls = [];

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    calls.add((path: path, data: data, requiresAuth: requiresAuth));
    return canned[path];
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    calls.add((path: path, data: null, requiresAuth: requiresAuth));
    return canned[path];
  }

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    calls.add((path: path, data: data, requiresAuth: requiresAuth));
    return canned[path];
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    calls.add((path: path, data: null, requiresAuth: requiresAuth));
    return canned[path];
  }
}

const _profileBody = {
  'id': '787d19cd-1fcd-45c8-8471-351530aa81db',
  'user_id': '884eea52-b977-4b1e-a548-54167798c045',
  'first_name': 'Test',
  'last_name': 'Doctor',
  'full_name': 'Test Doctor',
  'photo_file_id': null,
  'headline': null,
  'about': null,
  'primary_specialization_id': null,
  'clinical_interests': <String>[],
  'professional_location': <String, dynamic>{},
  'experience_years': 0.0,
  'open_to_opportunities': false,
  'verification_status': 'UNVERIFIED',
  'is_verified': false,
  'created_at': '2026-08-09T02:03:24.303453+00:00',
  'updated_at': '2026-08-09T02:06:54.457428+00:00',
};

void main() {
  late _RecordingApiClient apiClient;
  late DoctorProfileRemoteDataSource dataSource;

  setUp(() {
    apiClient = _RecordingApiClient(const {
      ApiEndpoints.doctorProfileCreate: _profileBody,
      ApiEndpoints.doctorProfileMe: _profileBody,
      ApiEndpoints.doctorPhotoUpload: {'photo_file_id': 'photo-1'},
    });
    dataSource = DoctorProfileRemoteDataSourceImpl(apiClient: apiClient);
  });

  test(
    'create posts to the doctor profile path as an authenticated request',
    () async {
      final profile = await dataSource.create(
        const DoctorProfileCreateModel(firstName: 'Test', lastName: 'Doctor'),
      );

      final call = apiClient.calls.single;
      expect(call.path, ApiEndpoints.doctorProfileCreate);
      expect(call.requiresAuth, isTrue);
      expect((call.data as Map)['first_name'], 'Test');
      expect((call.data as Map)['last_name'], 'Doctor');
      expect(profile.id, '787d19cd-1fcd-45c8-8471-351530aa81db');
    },
  );

  test(
    'getMyProfile gets the profile/me path as an authenticated request',
    () async {
      final profile = await dataSource.getMyProfile();

      final call = apiClient.calls.single;
      expect(call.path, ApiEndpoints.doctorProfileMe);
      expect(call.requiresAuth, isTrue);
      expect(profile.firstName, 'Test');
      expect(profile.fullName, 'Test Doctor');
    },
  );

  test(
    'update patches the profile/me path as an authenticated request',
    () async {
      final profile = await dataSource.update(
        const DoctorProfileUpdateModel(
          headline: 'Senior Consultant',
          openToOpportunities: true,
        ),
      );

      final call = apiClient.calls.single;
      expect(call.path, ApiEndpoints.doctorProfileMe);
      expect(call.requiresAuth, isTrue);
      expect((call.data as Map)['headline'], 'Senior Consultant');
      expect((call.data as Map)['open_to_opportunities'], isTrue);
      expect(profile.openToOpportunities, isFalse);
    },
  );

  test('getDoctorProfileById hits the doctor id path', () async {
    apiClient = _RecordingApiClient({
      ApiEndpoints.doctorProfileById('doc-42'): _profileBody,
    });
    dataSource = DoctorProfileRemoteDataSourceImpl(apiClient: apiClient);

    final profile = await dataSource.getDoctorProfileById('doc-42');

    final call = apiClient.calls.single;
    expect(call.path, ApiEndpoints.doctorProfileById('doc-42'));
    expect(call.requiresAuth, isTrue);
    expect(profile.id, '787d19cd-1fcd-45c8-8471-351530aa81db');
  });

  test('uploadPhoto posts multipart form data to the photo path', () async {
    final photoId = await dataSource.uploadPhoto(
      bytes: Uint8List.fromList([1, 2, 3]),
      filename: 'avatar.png',
      contentType: 'image/png',
    );

    final call = apiClient.calls.single;
    expect(call.path, ApiEndpoints.doctorPhotoUpload);
    expect(call.requiresAuth, isTrue);
    expect(call.data, isA<FormData>());
    expect(photoId, 'photo-1');
  });

  test(
    'uploadPhoto returns null when the backend does not echo a file id',
    () async {
      apiClient = _RecordingApiClient(const {
        ApiEndpoints.doctorPhotoUpload: <String, dynamic>{},
      });
      dataSource = DoctorProfileRemoteDataSourceImpl(apiClient: apiClient);

      final photoId = await dataSource.uploadPhoto(
        bytes: Uint8List.fromList([1]),
        filename: 'a.jpg',
        contentType: 'image/jpeg',
      );

      expect(photoId, isNull);
    },
  );

  test('listQualifications maps the list response', () async {
    apiClient = _RecordingApiClient(const {
      ApiEndpoints.doctorQualifications: [
        {
          'id': 'q-1',
          'degree': 'MBBS',
          'institution': 'GMC Mumbai',
          'year': 2012,
          'specialization': 'Cardiology',
        },
      ],
    });
    dataSource = DoctorProfileRemoteDataSourceImpl(apiClient: apiClient);

    final list = await dataSource.listQualifications();

    final call = apiClient.calls.single;
    expect(call.path, ApiEndpoints.doctorQualifications);
    expect(list.single.degree, 'MBBS');
    expect(list.single.specialization, 'Cardiology');
  });

  test(
    'addQualification posts the create body and parses the trimmed reply',
    () async {
      apiClient = _RecordingApiClient(const {
        ApiEndpoints.doctorQualifications: {
          'id': 'q-1',
          'degree': 'MBBS',
          'institution': 'GMC Mumbai',
          'year': 2012,
        },
      });
      dataSource = DoctorProfileRemoteDataSourceImpl(apiClient: apiClient);

      final result = await dataSource.addQualification(
        const DoctorQualificationModel(
          degree: 'MBBS',
          institution: 'GMC Mumbai',
          year: 2012,
        ),
      );

      final call = apiClient.calls.single;
      expect(call.path, ApiEndpoints.doctorQualifications);
      expect((call.data as Map)['year'], 2012);
      expect(result.id, 'q-1');
      expect(result.specialization, isNull);
    },
  );

  test('deleteQualification hits the qualification id path', () async {
    await dataSource.deleteQualification('q-1');

    final call = apiClient.calls.single;
    expect(call.path, ApiEndpoints.doctorQualificationById('q-1'));
    expect(call.requiresAuth, isTrue);
  });

  test('listRegistrations maps the list response', () async {
    apiClient = _RecordingApiClient(const {
      ApiEndpoints.doctorRegistrations: [
        {
          'id': 'r-1',
          'council_id': 'MCI',
          'registration_number': 'MCI-123',
          'registration_year': 2013,
          'is_primary': true,
        },
      ],
    });
    dataSource = DoctorProfileRemoteDataSourceImpl(apiClient: apiClient);

    final list = await dataSource.listRegistrations();

    expect(list.single.councilId, 'MCI');
    expect(list.single.isPrimary, isTrue);
  });

  test('addRegistration posts the create body', () async {
    apiClient = _RecordingApiClient(const {
      ApiEndpoints.doctorRegistrations: {
        'id': 'r-1',
        'council_id': 'MCI',
        'registration_number': 'MCI-123',
        'registration_year': 2013,
        'is_primary': false,
      },
    });
    dataSource = DoctorProfileRemoteDataSourceImpl(apiClient: apiClient);

    final result = await dataSource.addRegistration(
      const DoctorRegistrationModel(
        councilId: 'MCI',
        registrationNumber: 'MCI-123',
        registrationYear: 2013,
      ),
    );

    final call = apiClient.calls.single;
    expect((call.data as Map)['council_id'], 'MCI');
    expect(result.id, 'r-1');
  });

  test('listExperiences maps the full list response', () async {
    apiClient = _RecordingApiClient(const {
      ApiEndpoints.doctorExperiences: [
        {
          'id': 'e-1',
          'role': 'Resident Physician',
          'hospital_name': 'City General Hospital',
          'location': 'Mumbai',
          'start_date': '2013-06-01',
          'end_date': '2015-06-01',
          'is_current': false,
        },
      ],
    });
    dataSource = DoctorProfileRemoteDataSourceImpl(apiClient: apiClient);

    final list = await dataSource.listExperiences();

    expect(list.single.role, 'Resident Physician');
    expect(list.single.startDate, '2013-06-01');
  });

  test(
    'addExperience posts the create body and parses the trimmed reply',
    () async {
      apiClient = _RecordingApiClient(const {
        ApiEndpoints.doctorExperiences: {
          'id': 'e-1',
          'role': 'Resident Physician',
          'hospital_name': 'City General Hospital',
          'is_current': false,
        },
      });
      dataSource = DoctorProfileRemoteDataSourceImpl(apiClient: apiClient);

      final result = await dataSource.addExperience(
        const DoctorExperienceModel(
          role: 'Resident Physician',
          hospitalName: 'City General Hospital',
          startDate: '2013-06-01',
        ),
      );

      final call = apiClient.calls.single;
      expect((call.data as Map)['start_date'], '2013-06-01');
      expect(result.id, 'e-1');
      expect(result.location, isNull);
    },
  );

  test('deleteExperience hits the experience id path', () async {
    await dataSource.deleteExperience('e-1');

    final call = apiClient.calls.single;
    expect(call.path, ApiEndpoints.doctorExperienceById('e-1'));
    expect(call.requiresAuth, isTrue);
  });
}
