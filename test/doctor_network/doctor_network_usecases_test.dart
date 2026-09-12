import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/features/doctor_network/domain/entities/doctor_search_query.dart';
import 'package:doc_connect_app/features/doctor_network/domain/usecases/get_public_doctor_profile.dart';
import 'package:doc_connect_app/features/doctor_network/domain/usecases/search_doctors.dart';

import '../helpers/fake_doctor_network_repository.dart';

void main() {
  group('SearchDoctors', () {
    test('delegates to the repository and returns its page', () async {
      final repository = FakeDoctorNetworkRepository();
      final usecase = SearchDoctors(repository);

      final result = await usecase.call(
        const DoctorSearchQuery(search: 'Ahmed', page: 2),
      );

      expect(repository.searchCalls, 1);
      expect(repository.lastQuery?.search, 'Ahmed');
      expect(repository.lastQuery?.page, 2);
      expect(result.total, 0);
    });
  });

  group('GetPublicDoctorProfile', () {
    test('delegates to the repository with the given id', () async {
      final repository = FakeDoctorNetworkRepository();
      final usecase = GetPublicDoctorProfile(repository);

      final profile = await usecase.call('doc-42');

      expect(repository.profileCalls, 1);
      expect(repository.lastDoctorId, 'doc-42');
      expect(profile.id, 'doc-42');
    });
  });
}
