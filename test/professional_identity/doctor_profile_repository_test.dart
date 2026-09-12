import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/errors/exceptions.dart';
import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/features/professional_identity/data/datasources/doctor_profile_remote_data_source.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_experience_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_profile_create_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_profile_response_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_profile_update_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_qualification_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/models/doctor_registration_model.dart';
import 'package:doc_connect_app/features/professional_identity/data/repositories/doctor_profile_repository_impl.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_verification_status.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/location.dart';

class _FakeDoctorProfileRemoteDataSource implements DoctorProfileRemoteDataSource {
  DoctorProfileCreateModel? lastCreate;
  DoctorProfileUpdateModel? lastUpdate;
  DoctorQualificationModel? lastQualification;
  DoctorRegistrationModel? lastRegistration;
  DoctorExperienceModel? lastExperience;
  String? lastDeletedQualificationId;
  String? lastDeletedExperienceId;
  List<int>? lastPhotoBytes;
  int getCalls = 0;
  DoctorProfileResponseModel? result;
  List<DoctorQualificationModel> qualifications = [];
  List<DoctorRegistrationModel> registrations = [];
  List<DoctorExperienceModel> experiences = [];
  String? photoFileId;
  ApiException? errorToThrow;

  @override
  Future<DoctorProfileResponseModel> create(
    DoctorProfileCreateModel request,
  ) async {
    lastCreate = request;
    if (errorToThrow != null) throw errorToThrow!;
    return result!;
  }

  @override
  Future<DoctorProfileResponseModel> getMyProfile() async {
    getCalls++;
    if (errorToThrow != null) throw errorToThrow!;
    return result!;
  }

  @override
  Future<DoctorProfileResponseModel> getDoctorProfileById(String doctorId) async {
    getCalls++;
    if (errorToThrow != null) throw errorToThrow!;
    return result!;
  }

  @override
  Future<DoctorProfileResponseModel> update(
    DoctorProfileUpdateModel request,
  ) async {
    lastUpdate = request;
    if (errorToThrow != null) throw errorToThrow!;
    return result!;
  }

  @override
  Future<String?> uploadPhoto({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) async {
    lastPhotoBytes = bytes;
    if (errorToThrow != null) throw errorToThrow!;
    return photoFileId;
  }

  @override
  Future<List<DoctorQualificationModel>> listQualifications() async {
    if (errorToThrow != null) throw errorToThrow!;
    return qualifications;
  }

  @override
  Future<DoctorQualificationModel> addQualification(
    DoctorQualificationModel request,
  ) async {
    lastQualification = request;
    if (errorToThrow != null) throw errorToThrow!;
    return request;
  }

  @override
  Future<void> deleteQualification(String qualificationId) async {
    lastDeletedQualificationId = qualificationId;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<List<DoctorRegistrationModel>> listRegistrations() async {
    if (errorToThrow != null) throw errorToThrow!;
    return registrations;
  }

  @override
  Future<DoctorRegistrationModel> addRegistration(
    DoctorRegistrationModel request,
  ) async {
    lastRegistration = request;
    if (errorToThrow != null) throw errorToThrow!;
    return request;
  }

  @override
  Future<List<DoctorExperienceModel>> listExperiences() async {
    if (errorToThrow != null) throw errorToThrow!;
    return experiences;
  }

  @override
  Future<DoctorExperienceModel> addExperience(
    DoctorExperienceModel request,
  ) async {
    lastExperience = request;
    if (errorToThrow != null) throw errorToThrow!;
    return request;
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    lastDeletedExperienceId = experienceId;
    if (errorToThrow != null) throw errorToThrow!;
  }
}

const _result = DoctorProfileResponseModel(
  id: 'p-1',
  userId: 'u-1',
  firstName: 'Ada',
  lastName: 'Lovelace',
  fullName: 'Ada Lovelace',
  verificationStatus: DoctorVerificationStatus.unverified,
);

void main() {
  late _FakeDoctorProfileRemoteDataSource dataSource;
  late DoctorProfileRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeDoctorProfileRemoteDataSource();
    repository = DoctorProfileRepositoryImpl(remoteDataSource: dataSource);
  });

  group('createProfile', () {
    setUp(() => dataSource.result = _result);

    test('forwards params and maps the response to an entity', () async {
      final profile = await repository.createProfile(
        firstName: 'Ada',
        lastName: 'Lovelace',
        headline: 'Mathematician',
        clinicalInterests: const ['computing'],
        professionalLocation: const Location(city: 'London', state: 'UK'),
        experienceYears: 5,
      );

      expect(dataSource.lastCreate?.firstName, 'Ada');
      expect(dataSource.lastCreate?.lastName, 'Lovelace');
      expect(dataSource.lastCreate?.headline, 'Mathematician');
      expect(dataSource.lastCreate?.clinicalInterests, ['computing']);
      expect(dataSource.lastCreate?.professionalLocation?.city, 'London');
      expect(dataSource.lastCreate?.experienceYears, 5);
      expect(profile.id, 'p-1');
      expect(profile.displayName, 'Ada Lovelace');
    });

    test('maps a backend ApiException to a Failure', () async {
      dataSource.errorToThrow = ValidationException(message: 'first_name: required');

      await expectLater(
        repository.createProfile(firstName: '', lastName: ''),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('getMyProfile', () {
    setUp(() => dataSource.result = _result);

    test('fetches and maps the caller profile', () async {
      final profile = await repository.getMyProfile();

      expect(dataSource.getCalls, 1);
      expect(profile.userId, 'u-1');
      expect(profile.verificationStatus, DoctorVerificationStatus.unverified);
    });

    test('maps an unauthorized exception to UnauthorizedFailure', () async {
      dataSource.errorToThrow = UnauthorizedException(message: 'expired');

      await expectLater(
        repository.getMyProfile(),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });
  });

  group('getDoctorProfileById', () {
    setUp(() => dataSource.result = _result);

    test('fetches and maps a public profile by id', () async {
      final profile = await repository.getDoctorProfileById('doc-7');

      expect(dataSource.getCalls, 1);
      expect(profile.id, 'p-1');
    });

    test('maps a backend ApiException to a Failure', () async {
      dataSource.errorToThrow = NotFoundException(message: 'missing');

      await expectLater(
        repository.getDoctorProfileById('doc-7'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('updateProfile', () {
    setUp(() => dataSource.result = _result);

    test('forwards only the provided fields', () async {
      final profile = await repository.updateProfile(
        headline: 'Senior Consultant',
        openToOpportunities: true,
      );

      expect(dataSource.lastUpdate?.headline, 'Senior Consultant');
      expect(dataSource.lastUpdate?.openToOpportunities, isTrue);
      expect(dataSource.lastUpdate?.firstName, isNull);
      expect(profile.id, 'p-1');
    });

    test('maps a backend ApiException to a Failure', () async {
      dataSource.errorToThrow =
          NotFoundException(message: 'profile not found');

      await expectLater(
        repository.updateProfile(about: 'New about'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('uploadProfilePhoto', () {
    test('forwards bytes and returns the photo file id', () async {
      dataSource.photoFileId = 'photo-9';
      final bytes = Uint8List.fromList([9, 8, 7]);

      final photoId = await repository.uploadProfilePhoto(
        bytes: bytes,
        filename: 'a.png',
        contentType: 'image/png',
      );

      expect(dataSource.lastPhotoBytes, bytes);
      expect(photoId, 'photo-9');
    });

    test('maps a backend ApiException to a Failure', () async {
      dataSource.errorToThrow = ValidationException(message: 'file required');

      await expectLater(
        repository.uploadProfilePhoto(
          bytes: Uint8List.fromList([1]),
          filename: 'a.png',
          contentType: 'image/png',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('qualifications', () {
    test('listQualifications maps model to entity', () async {
      dataSource.qualifications = [
        const DoctorQualificationModel(
          id: 'q-1',
          degree: 'MBBS',
          institution: 'GMC',
          year: 2012,
        ),
      ];

      final list = await repository.listQualifications();

      expect(list.single.degree, 'MBBS');
      expect(list.single.id, 'q-1');
    });

    test('addQualification forwards params', () async {
      final item = await repository.addQualification(
        degree: 'MBBS',
        institution: 'GMC',
        year: 2012,
        specialization: 'Cardiology',
      );

      expect(dataSource.lastQualification?.degree, 'MBBS');
      expect(dataSource.lastQualification?.specialization, 'Cardiology');
      expect(item.institution, 'GMC');
    });

    test('deleteQualification forwards the id', () async {
      await repository.deleteQualification('q-1');

      expect(dataSource.lastDeletedQualificationId, 'q-1');
    });

    test('maps a backend ApiException to a Failure', () async {
      dataSource.errorToThrow = NotFoundException(message: 'no such q');

      await expectLater(
        repository.deleteQualification('q-1'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('registrations', () {
    test('listRegistrations maps model to entity', () async {
      dataSource.registrations = [
        const DoctorRegistrationModel(
          id: 'r-1',
          councilId: 'MCI',
          registrationNumber: 'MCI-1',
          registrationYear: 2013,
        ),
      ];

      final list = await repository.listRegistrations();

      expect(list.single.councilId, 'MCI');
    });

    test('addRegistration forwards params', () async {
      final item = await repository.addRegistration(
        councilId: 'MCI',
        registrationNumber: 'MCI-1',
        registrationYear: 2013,
        isPrimary: true,
      );

      expect(dataSource.lastRegistration?.councilId, 'MCI');
      expect(dataSource.lastRegistration?.isPrimary, isTrue);
      expect(item.registrationNumber, 'MCI-1');
    });
  });

  group('experiences', () {
    test('listExperiences maps model to entity', () async {
      dataSource.experiences = [
        const DoctorExperienceModel(
          id: 'e-1',
          role: 'Resident',
          hospitalName: 'City Hospital',
          startDate: '2013-06-01',
        ),
      ];

      final list = await repository.listExperiences();

      expect(list.single.role, 'Resident');
      expect(list.single.startDate, '2013-06-01');
    });

    test('addExperience forwards params', () async {
      final item = await repository.addExperience(
        role: 'Resident',
        hospitalName: 'City Hospital',
        location: 'Mumbai',
        startDate: '2013-06-01',
        isCurrent: false,
      );

      expect(dataSource.lastExperience?.role, 'Resident');
      expect(dataSource.lastExperience?.location, 'Mumbai');
      expect(item.hospitalName, 'City Hospital');
    });

    test('deleteExperience forwards the id', () async {
      await repository.deleteExperience('e-1');

      expect(dataSource.lastDeletedExperienceId, 'e-1');
    });

    test('maps a backend ApiException to a Failure', () async {
      dataSource.errorToThrow = ValidationException(message: 'role required');

      await expectLater(
        repository.addExperience(role: '', hospitalName: ''),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
