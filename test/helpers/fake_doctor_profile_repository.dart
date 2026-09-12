import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_experience.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_profile.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_qualification.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_registration.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/location.dart';
import 'package:doc_connect_app/features/professional_identity/domain/repositories/doctor_profile_repository.dart';

/// Configurable in-memory [DoctorProfileRepository] for bloc and widget tests.
///
/// Throws [Failure]s from [getFailure] for mutations and profile reads, and
/// from the per-resource failure slots for the list reads.
class FakeDoctorProfileRepository implements DoctorProfileRepository {
  DoctorProfile result = const DoctorProfile(
    id: 'p-1',
    userId: 'u-1',
    firstName: 'Ada',
    lastName: 'Lovelace',
    fullName: 'Ada Lovelace',
  );

  Failure? getFailure;
  Failure? listQualificationFailure;
  Failure? listRegistrationFailure;
  Failure? listExperienceFailure;

  /// When set, profile reads await this delay first (lets tests observe the
  /// transient loading state under fake-async `pump`s).
  Duration? getDelay;

  int getCalls = 0;
  int uploadCalls = 0;
  int addQualificationCalls = 0;
  int deleteQualificationCalls = 0;
  int addRegistrationCalls = 0;
  int addExperienceCalls = 0;
  int deleteExperienceCalls = 0;

  List<DoctorQualification> qualifications = const [];
  List<DoctorRegistration> registrations = const [];
  List<DoctorExperience> experiences = const [];

  @override
  Future<DoctorProfile> getMyProfile() async {
    if (getDelay != null) await Future<void>.delayed(getDelay!);
    getCalls++;
    if (getFailure != null) throw getFailure!;
    return result;
  }

  @override
  Future<DoctorProfile> getDoctorProfileById(String doctorId) async {
    if (getFailure != null) throw getFailure!;
    return result;
  }

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
    if (getFailure != null) throw getFailure!;
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
    if (getFailure != null) throw getFailure!;
    return result;
  }

  @override
  Future<String?> uploadProfilePhoto({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) async {
    uploadCalls++;
    if (getFailure != null) throw getFailure!;
    return 'photo-1';
  }

  @override
  Future<List<DoctorQualification>> listQualifications() async {
    if (listQualificationFailure != null) throw listQualificationFailure!;
    return qualifications;
  }

  @override
  Future<DoctorQualification> addQualification({
    required String degree,
    required String institution,
    required int year,
    String? specialization,
  }) async {
    addQualificationCalls++;
    if (getFailure != null) throw getFailure!;
    return DoctorQualification(
      degree: degree,
      institution: institution,
      year: year,
      specialization: specialization,
    );
  }

  @override
  Future<void> deleteQualification(String qualificationId) async {
    deleteQualificationCalls++;
    if (getFailure != null) throw getFailure!;
  }

  @override
  Future<List<DoctorRegistration>> listRegistrations() async {
    if (listRegistrationFailure != null) throw listRegistrationFailure!;
    return registrations;
  }

  @override
  Future<DoctorRegistration> addRegistration({
    required String councilId,
    required String registrationNumber,
    required int registrationYear,
    bool isPrimary = false,
  }) async {
    addRegistrationCalls++;
    if (getFailure != null) throw getFailure!;
    return DoctorRegistration(
      councilId: councilId,
      registrationNumber: registrationNumber,
      registrationYear: registrationYear,
      isPrimary: isPrimary,
    );
  }

  @override
  Future<List<DoctorExperience>> listExperiences() async {
    if (listExperienceFailure != null) throw listExperienceFailure!;
    return experiences;
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
    addExperienceCalls++;
    if (getFailure != null) throw getFailure!;
    return DoctorExperience(
      role: role,
      hospitalName: hospitalName,
      startDate: startDate,
      isCurrent: isCurrent,
    );
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    deleteExperienceCalls++;
    if (getFailure != null) throw getFailure!;
  }
}
