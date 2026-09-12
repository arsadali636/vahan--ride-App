import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/enums/verification_status.dart';
import 'package:doc_connect_app/core/models/user_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test('parses snake_case wire keys', () {
      final model = UserModel.fromJson(const {
        'id': 'u-1',
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'email': 'ada@mednexus.io',
        'profile_image': 'https://example.com/a.jpg',
        'professional_headline': 'Cardiologist',
        'primary_specialization_id': 'spec-7',
        'qualification': 'MD',
        'verification_status': 'verified',
      });

      expect(model.id, 'u-1');
      expect(model.firstName, 'Ada');
      expect(model.lastName, 'Lovelace');
      expect(model.email, 'ada@mednexus.io');
      expect(model.profileImage, 'https://example.com/a.jpg');
      expect(model.professionalHeadline, 'Cardiologist');
      expect(model.primarySpecializationId, 'spec-7');
      expect(model.qualification, 'MD');
      expect(model.verificationStatus, VerificationStatus.verified);
    });

    test('is null-safe when keys are absent', () {
      final model = UserModel.fromJson(const {});
      expect(model, isA<UserModel>());
      expect(model.email, isNull);
      expect(model.verificationStatus, isNull);
    });

    test('maps unknown verification status to null', () {
      final model = UserModel.fromJson(const {
        'verification_status': 'flying_carpet',
      });
      expect(model.verificationStatus, isNull);
    });
  });

  group('UserModel.toJson', () {
    test('emits snake_case wire keys', () {
      const model = UserModel(
        id: 'u-1',
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@mednexus.io',
        professionalHeadline: 'Cardiologist',
        verificationStatus: VerificationStatus.pending,
      );

      expect(model.toJson(), {
        'id': 'u-1',
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'email': 'ada@mednexus.io',
        'profile_image': null,
        'professional_headline': 'Cardiologist',
        'primary_specialization_id': null,
        'qualification': null,
        'verification_status': 'pending',
      });
    });

    test('round-trips through fromJson', () {
      const model = UserModel(
        id: 'u-1',
        firstName: 'Ada',
        lastName: 'Lovelace',
        email: 'ada@mednexus.io',
        profileImage: 'https://example.com/a.jpg',
        professionalHeadline: 'Cardiologist',
        primarySpecializationId: 'spec-7',
        qualification: 'MD',
        verificationStatus: VerificationStatus.rejected,
      );

      expect(UserModel.fromJson(model.toJson()), model);
    });
  });
}
