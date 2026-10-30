import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/features/doctor_network/data/models/doctor_search_query_model.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/doctor_search_query.dart';

void main() {
  group('DoctorSearchQueryModel.toQueryParameters', () {
    test('maps every domain field to the backend query parameters', () {
      final model = DoctorSearchQueryModel.fromDomain(
        const DoctorSearchQuery(
          search: 'Ahmed',
          specialty: 'Cardiology',
          city: 'Mumbai',
          experienceMin: 5,
          openToOpportunities: true,
          page: 3,
          pageSize: 10,
        ),
      );

      expect(model.toQueryParameters(), {
        'search': 'Ahmed',
        'specialty': 'Cardiology',
        'city': 'Mumbai',
        'experience_min': 5,
        'open_to_opportunities': true,
        'page': 3,
        'page_size': 10,
      });
    });

    test('omits null filters but always sends page and page_size', () {
      final model = DoctorSearchQueryModel.fromDomain(
        const DoctorSearchQuery(),
      );

      expect(model.toQueryParameters(), {'page': 1, 'page_size': 20});
    });

    test('omits empty-string filters', () {
      final model = DoctorSearchQueryModel.fromDomain(
        const DoctorSearchQuery(
          search: '',
          specialty: '  ',
          page: 2,
          pageSize: 50,
        ),
      );

      expect(model.toQueryParameters(), {'page': 2, 'page_size': 50});
    });

    test('preserves experience_min of zero', () {
      final model = DoctorSearchQueryModel.fromDomain(
        const DoctorSearchQuery(experienceMin: 0),
      );

      expect(model.toQueryParameters()['experience_min'], 0);
    });

    test('preserves open_to_opportunities false', () {
      final model = DoctorSearchQueryModel.fromDomain(
        const DoctorSearchQuery(openToOpportunities: false),
      );

      expect(model.toQueryParameters()['open_to_opportunities'], isFalse);
    });
  });
}
