import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_experience.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_profile.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_qualification.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_registration.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_verification_status.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/location.dart';
import 'package:doc_connect_app/features/professional_identity/domain/repositories/doctor_profile_repository.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/add_experience_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/add_qualification_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/add_registration_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/create_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/delete_experience_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/delete_qualification_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/get_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/get_doctor_profile_by_id_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/list_experiences_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/list_qualifications_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/list_registrations_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/update_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/upload_profile_photo_usecase.dart';

class _FakeRepository implements DoctorProfileRepository {
  final List<Map<String, dynamic>> calls = [];
  DoctorProfile result = const DoctorProfile(
    id: 'p-1',
    userId: 'u-1',
    firstName: 'Ada',
    lastName: 'Lovelace',
    fullName: 'Ada Lovelace',
  );

  @override
  Future<DoctorProfile> createProfile({
    required String firstName,
    required String lastName,
    String? headline,
    String? about,
    String? primarySpecializationId,
    List<String>? clinicalInterests,
    Location? professionalLocation,
    double? experienceYears,
  }) async {
    calls.add({'op': 'create', 'firstName': firstName, 'lastName': lastName});
    return result;
  }

  @override
  Future<DoctorProfile> getMyProfile() async {
    calls.add({'op': 'get'});
    return result;
  }

  @override
  Future<DoctorProfile> getDoctorProfileById(String doctorId) async {
    calls.add({'op': 'getById', 'doctorId': doctorId});
    return result;
  }

  @override
  Future<DoctorProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? headline,
    String? about,
    String? primarySpecializationId,
    List<String>? clinicalInterests,
    Location? professionalLocation,
    double? experienceYears,
    bool? openToOpportunities,
  }) async {
    calls.add({'op': 'update', 'headline': headline});
    return result;
  }

  @override
  Future<String?> uploadProfilePhoto({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) async {
    calls.add({'op': 'upload', 'filename': filename});
    return 'photo-1';
  }

  @override
  Future<List<DoctorQualification>> listQualifications() async {
    calls.add({'op': 'listQualifications'});
    return const [
      DoctorQualification(
        id: 'q-1',
        degree: 'MBBS',
        institution: 'GMC',
        year: 2012,
      ),
    ];
  }

  @override
  Future<DoctorQualification> addQualification({
    required String degree,
    required String institution,
    required int year,
    String? specialization,
  }) async {
    calls.add({'op': 'addQualification', 'degree': degree, 'year': year});
    return DoctorQualification(
      degree: degree,
      institution: institution,
      year: year,
      specialization: specialization,
    );
  }

  @override
  Future<void> deleteQualification(String qualificationId) async {
    calls.add({'op': 'deleteQualification', 'id': qualificationId});
  }

  @override
  Future<List<DoctorRegistration>> listRegistrations() async {
    calls.add({'op': 'listRegistrations'});
    return const [
      DoctorRegistration(
        id: 'r-1',
        councilId: 'MCI',
        registrationNumber: 'MCI-1',
        registrationYear: 2013,
      ),
    ];
  }

  @override
  Future<DoctorRegistration> addRegistration({
    required String councilId,
    required String registrationNumber,
    required int registrationYear,
    bool isPrimary = false,
  }) async {
    calls.add({
      'op': 'addRegistration',
      'councilId': councilId,
      'registrationYear': registrationYear,
    });
    return DoctorRegistration(
      councilId: councilId,
      registrationNumber: registrationNumber,
      registrationYear: registrationYear,
      isPrimary: isPrimary,
    );
  }

  @override
  Future<List<DoctorExperience>> listExperiences() async {
    calls.add({'op': 'listExperiences'});
    return const [
      DoctorExperience(
        id: 'e-1',
        role: 'Resident',
        hospitalName: 'City Hospital',
      ),
    ];
  }

  @override
  Future<DoctorExperience> addExperience({
    required String role,
    required String hospitalName,
    String? location,
    String? startDate,
    String? endDate,
    bool isCurrent = false,
    String? description,
  }) async {
    calls.add({'op': 'addExperience', 'role': role});
    return DoctorExperience(
      role: role,
      hospitalName: hospitalName,
      startDate: startDate,
      isCurrent: isCurrent,
    );
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    calls.add({'op': 'deleteExperience', 'id': experienceId});
  }
}

void main() {
  late _FakeRepository repository;

  setUp(() {
    repository = _FakeRepository();
  });

  test('CreateDoctorProfile delegates required + optional params', () async {
    final useCase = CreateDoctorProfile(repository);

    final profile = await useCase(
      firstName: 'Ada',
      lastName: 'Lovelace',
      headline: 'Mathematician',
    );

    expect(repository.calls.single, {
      'op': 'create',
      'firstName': 'Ada',
      'lastName': 'Lovelace',
    });
    expect(profile.id, 'p-1');
  });

  test('GetDoctorProfile returns the fetched profile', () async {
    final useCase = GetDoctorProfile(repository);

    final profile = await useCase();

    expect(repository.calls.single, {'op': 'get'});
    expect(profile.displayName, 'Ada Lovelace');
  });

  test('GetDoctorProfileById delegates the doctor id', () async {
    final useCase = GetDoctorProfileById(repository);

    final profile = await useCase('doc-7');

    expect(repository.calls.single, {'op': 'getById', 'doctorId': 'doc-7'});
    expect(profile.id, 'p-1');
  });

  test('UpdateDoctorProfile delegates partial fields', () async {
    final useCase = UpdateDoctorProfile(repository);

    final profile = await useCase(
      headline: 'Senior Consultant',
      openToOpportunities: true,
    );

    expect(repository.calls.single, {
      'op': 'update',
      'headline': 'Senior Consultant',
    });
    expect(profile.verificationStatus, DoctorVerificationStatus.unverified);
  });

  test('UploadProfilePhoto forwards the file details', () async {
    final useCase = UploadProfilePhoto(repository);

    final photoId = await useCase(
      bytes: [1, 2, 3],
      filename: 'a.png',
      contentType: 'image/png',
    );

    expect(repository.calls.single, {'op': 'upload', 'filename': 'a.png'});
    expect(photoId, 'photo-1');
  });

  test('ListQualifications returns the mapped list', () async {
    final useCase = ListQualifications(repository);

    final list = await useCase();

    expect(repository.calls.single, {'op': 'listQualifications'});
    expect(list.single.degree, 'MBBS');
  });

  test('AddQualification delegates the fields', () async {
    final useCase = AddQualification(repository);

    final item = await useCase(
      degree: 'MBBS',
      institution: 'GMC',
      year: 2012,
      specialization: 'Cardiology',
    );

    expect(repository.calls.single, {
      'op': 'addQualification',
      'degree': 'MBBS',
      'year': 2012,
    });
    expect(item.specialization, 'Cardiology');
  });

  test('DeleteQualification delegates the id', () async {
    final useCase = DeleteQualification(repository);

    await useCase('q-1');

    expect(repository.calls.single, {'op': 'deleteQualification', 'id': 'q-1'});
  });

  test('ListRegistrations returns the mapped list', () async {
    final useCase = ListRegistrations(repository);

    final list = await useCase();

    expect(repository.calls.single, {'op': 'listRegistrations'});
    expect(list.single.councilId, 'MCI');
  });

  test('AddRegistration delegates the fields', () async {
    final useCase = AddRegistration(repository);

    final item = await useCase(
      councilId: 'MCI',
      registrationNumber: 'MCI-1',
      registrationYear: 2013,
      isPrimary: true,
    );

    expect(repository.calls.single, {
      'op': 'addRegistration',
      'councilId': 'MCI',
      'registrationYear': 2013,
    });
    expect(item.isPrimary, isTrue);
  });

  test('ListExperiences returns the mapped list', () async {
    final useCase = ListExperiences(repository);

    final list = await useCase();

    expect(repository.calls.single, {'op': 'listExperiences'});
    expect(list.single.role, 'Resident');
  });

  test('AddExperience delegates the fields', () async {
    final useCase = AddExperience(repository);

    final item = await useCase(
      role: 'Resident',
      hospitalName: 'City Hospital',
      startDate: '2013-06-01',
    );

    expect(repository.calls.single, {'op': 'addExperience', 'role': 'Resident'});
    expect(item.startDate, '2013-06-01');
  });

  test('DeleteExperience delegates the id', () async {
    final useCase = DeleteExperience(repository);

    await useCase('e-1');

    expect(repository.calls.single, {'op': 'deleteExperience', 'id': 'e-1'});
  });
}
