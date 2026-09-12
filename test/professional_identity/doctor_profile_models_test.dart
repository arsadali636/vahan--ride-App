import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/features/professional_identity/data/models/doctor_profile_create_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_profile_response_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_profile_update_model.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_verification_status.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/location.dart';

const _liveProfileJson = {
  'id': '787d19cd-1fcd-45c8-8471-351530aa81db',
  'user_id': '884eea52-b977-4b1e-a548-54167798c045',
  'first_name': 'Test',
  'last_name': 'Doctor',
  'full_name': 'Test Doctor',
  'photo_file_id': null,
  'headline': null,
  'about': null,
  'primary_specialization_id': null,
  'clinical_interests': [],
  'professional_location': <String, dynamic>{},
  'experience_years': 0,
  'open_to_opportunities': false,
  'verification_status': 'UNVERIFIED',
  'is_verified': false,
  'created_at': '2026-08-09T02:03:24.303453+00:00',
  'updated_at': '2026-08-09T02:03:24.303464+00:00',
};

void main() {
  group('DoctorProfileCreateModel', () {
    test('serializes only the required fields when optional values are null',
        () {
      const model = DoctorProfileCreateModel(
        firstName: 'Ada',
        lastName: 'Lovelace',
      );

      expect(model.toJson(), {
        'first_name': 'Ada',
        'last_name': 'Lovelace',
      });
    });

    test('serializes every optional field when provided', () {
      const model = DoctorProfileCreateModel(
        firstName: 'Ada',
        lastName: 'Lovelace',
        headline: 'Software pioneer',
        about: 'First programmer.',
        primarySpecializationId: 'spec-1',
        clinicalInterests: ['mathematics', 'computing'],
        professionalLocation: Location(city: 'London', state: 'UK'),
        experienceYears: 5,
      );

      expect(model.toJson(), {
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'headline': 'Software pioneer',
        'about': 'First programmer.',
        'primary_specialization_id': 'spec-1',
        'clinical_interests': ['mathematics', 'computing'],
        'professional_location': {'city': 'London', 'state': 'UK'},
        'experience_years': 5,
      });
    });
  });

  group('DoctorProfileUpdateModel', () {
    test('omits null fields for a partial update', () {
      const model = DoctorProfileUpdateModel(
        headline: 'New headline',
        openToOpportunities: true,
      );

      expect(model.toJson(), {
        'headline': 'New headline',
        'open_to_opportunities': true,
      });
    });

    test('serializes an empty update to an empty body', () {
      expect(const DoctorProfileUpdateModel().toJson(), isEmpty);
    });
  });

  group('DoctorProfileResponseModel', () {
    test('parses the verbatim live backend profile response', () {
      final model = DoctorProfileResponseModel.fromJson(_liveProfileJson);

      expect(model.id, '787d19cd-1fcd-45c8-8471-351530aa81db');
      expect(model.userId, '884eea52-b977-4b1e-a548-54167798c045');
      expect(model.firstName, 'Test');
      expect(model.lastName, 'Doctor');
      expect(model.fullName, 'Test Doctor');
      expect(model.photoFileId, isNull);
      expect(model.headline, isNull);
      expect(model.primarySpecializationId, isNull);
      expect(model.clinicalInterests, isEmpty);
      expect(model.professionalLocation, isNull);
      expect(model.experienceYears, 0.0);
      expect(model.openToOpportunities, isFalse);
      expect(model.verificationStatus, DoctorVerificationStatus.unverified);
      expect(model.isVerified, isFalse);
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);

      final entity = model.toEntity();
      expect(entity.id, model.id);
      expect(entity.userId, model.userId);
      expect(entity.displayName, 'Test Doctor');
      expect(entity.verificationStatus, DoctorVerificationStatus.unverified);
      expect(entity.experienceYears, 0.0);
    });

    test('maps a verified wire value and tolerates an empty professional_location',
        () {
      final model = DoctorProfileResponseModel.fromJson({
        ..._liveProfileJson,
        'verification_status': 'VERIFIED',
        'is_verified': true,
        'experience_years': 12.5,
        'clinical_interests': ['cardiology'],
      });

      expect(model.verificationStatus, DoctorVerificationStatus.verified);
      expect(model.isVerified, isTrue);
      expect(model.experienceYears, 12.5);
      expect(model.clinicalInterests, ['cardiology']);
    });

    test('defaults missing fields to safe values', () {
      final model = DoctorProfileResponseModel.fromJson(const {
        'id': 'p-1',
        'user_id': 'u-1',
        'first_name': 'Ada',
        'last_name': 'Lovelace',
      });

      expect(model.fullName, '');
      expect(model.clinicalInterests, isEmpty);
      expect(model.experienceYears, 0.0);
      expect(model.verificationStatus, DoctorVerificationStatus.unverified);
      expect(model.createdAt, isNull);
      expect(model.professionalLocation, isNull);
    });

    test('parses a populated professional_location', () {
      final model = DoctorProfileResponseModel.fromJson({
        ..._liveProfileJson,
        'professional_location': {
          'address': '221B Baker Street',
          'city': 'London',
          'state': 'England',
          'pincode': 'NW1 6XE',
        },
      });

      final location = model.professionalLocation;
      expect(location, isNotNull);
      expect(location!.city, 'London');
      expect(location.state, 'England');
      expect(location.address, '221B Baker Street');
      expect(location.label, 'London, England');

      final entity = model.toEntity();
      expect(entity.professionalLocation?.city, 'London');
    });
  });
}
