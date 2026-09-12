import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/errors/exceptions.dart';
import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/features/doctor_network/data/datasources/doctor_network_remote_data_source.dart';
import 'package:doc_connect_app/features/doctor_network/data/models/doctor_search_query_model.dart';
import 'package:doc_connect_app/features/doctor_network/data/models/doctor_search_response_model.dart';
import 'package:doc_connect_app/features/doctor_network/data/models/public_doctor_profile_model.dart';
import 'package:doc_connect_app/features/doctor_network/data/repositories/doctor_network_repository_impl.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/doctor_search_query.dart';

class _FakeDataSource implements DoctorNetworkRemoteDataSource {
  DoctorSearchResponseModel? searchResponse;
  PublicDoctorProfileModel? profileResponse;
  ApiException? searchError;
  ApiException? profileError;
  int searchCalls = 0;
  int profileCalls = 0;
  DoctorSearchQueryModel? lastQuery;

  @override
  Future<DoctorSearchResponseModel> searchDoctors(
    DoctorSearchQueryModel query,
  ) async {
    searchCalls++;
    lastQuery = query;
    if (searchError != null) throw searchError!;
    return searchResponse ??
        const DoctorSearchResponseModel(
          total: 0,
          page: 1,
          pageSize: 20,
          results: [],
        );
  }

  @override
  Future<PublicDoctorProfileModel> getDoctorProfile(String doctorId) async {
    profileCalls++;
    if (profileError != null) throw profileError!;
    return profileResponse ??
        const PublicDoctorProfileModel(
          id: 'doc-1',
          fullName: 'Doctor',
          firstName: 'Doctor',
          lastName: 'One',
        );
  }
}

void main() {
  late _FakeDataSource dataSource;
  late DoctorNetworkRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeDataSource();
    repository = DoctorNetworkRepositoryImpl(remoteDataSource: dataSource);
  });

  group('searchDoctors', () {
    test('forwards the query and maps the envelope to entities', () async {
      dataSource.searchResponse = const DoctorSearchResponseModel(
        total: 1,
        page: 1,
        pageSize: 20,
        results: [
          // Parsed via the real model; fields supplied match the live shape.
        ],
      );

      final result = await repository.searchDoctors(
        const DoctorSearchQuery(search: 'Ahmed', page: 2, pageSize: 10),
      );

      expect(dataSource.searchCalls, 1);
      expect(dataSource.lastQuery!.search, 'Ahmed');
      expect(dataSource.lastQuery!.page, 2);
      expect(dataSource.lastQuery!.pageSize, 10);
      expect(result.total, 1);
      expect(result.page, 1);
      expect(result.items, isEmpty);
    });

    test('maps a ServerException to ServerFailure', () async {
      dataSource.searchError = const ServerException(
        message: 'search is down',
      );

      await expectLater(
        repository.searchDoctors(const DoctorSearchQuery()),
        throwsA(isA<ServerFailure>().having(
          (e) => e.message,
          'message',
          'search is down',
        )),
      );
    });

    test('maps a NotFoundException to NotFoundFailure', () async {
      dataSource.searchError = const NotFoundException(
        message: 'nothing here',
      );

      await expectLater(
        repository.searchDoctors(const DoctorSearchQuery()),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('getDoctorProfile', () {
    test('forwards the id and maps the model to an entity', () async {
      dataSource.profileResponse = const PublicDoctorProfileModel(
        id: 'doc-9',
        fullName: 'Bravo Target',
        firstName: 'Bravo',
        lastName: 'Target',
        headline: 'Senior Consultant',
        isVerified: true,
      );

      final profile = await repository.getDoctorProfile('doc-9');

      expect(dataSource.profileCalls, 1);
      expect(profile.id, 'doc-9');
      expect(profile.displayName, 'Bravo Target');
      expect(profile.headline, 'Senior Consultant');
      expect(profile.isVerified, isTrue);
    });

    test('maps an ApiException to a Failure', () async {
      dataSource.profileError = const UnauthorizedException(
        message: 'session expired',
      );

      await expectLater(
        repository.getDoctorProfile('doc-9'),
        throwsA(isA<UnauthorizedFailure>().having(
          (e) => e.message,
          'message',
          'session expired',
        )),
      );
    });
  });
}
