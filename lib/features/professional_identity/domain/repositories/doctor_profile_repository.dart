import '../entities/doctor_experience.dart';
import '../entities/doctor_profile.dart';
import '../entities/doctor_qualification.dart';
import '../entities/doctor_registration.dart';
import '../entities/location.dart';

/// Repository for the doctor's professional profile and its sub-resources
/// (qualifications, registrations and work experience).
abstract class DoctorProfileRepository {
  /// Creates a doctor profile. Requires at least [firstName] and [lastName].
  Future<DoctorProfile> createProfile({
    required String firstName,
    required String lastName,
    String? headline,
    String? about,
    String? primarySpecializationId,
    List<String>? clinicalInterests,
    Location? professionalLocation,
    double? experienceYears,
  });

  /// Fetches the caller's doctor profile.
  Future<DoctorProfile> getMyProfile();

  /// Fetches a public doctor profile by [doctorId].
  Future<DoctorProfile> getDoctorProfileById(String doctorId);

  /// Partially updates the caller's doctor profile. Every field is optional;
  /// null fields are left unchanged on the server.
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
  });

  /// Uploads a profile photo and returns the backend's `photo_file_id`.
  Future<String?> uploadProfilePhoto({
    required List<int> bytes,
    required String filename,
    required String contentType,
  });

  /// Lists the caller's qualifications.
  Future<List<DoctorQualification>> listQualifications();

  /// Adds a qualification.
  Future<DoctorQualification> addQualification({
    required String degree,
    required String institution,
    required int year,
    String? specialization,
  });

  /// Deletes a qualification.
  Future<void> deleteQualification(String qualificationId);

  /// Lists the caller's registrations.
  Future<List<DoctorRegistration>> listRegistrations();

  /// Adds a registration.
  Future<DoctorRegistration> addRegistration({
    required String councilId,
    required String registrationNumber,
    required int registrationYear,
    bool isPrimary = false,
  });

  /// Lists the caller's work-experience entries.
  Future<List<DoctorExperience>> listExperiences();

  /// Adds a work-experience entry.
  Future<DoctorExperience> addExperience({
    required String role,
    required String hospitalName,
    String? location,
    String? startDate,
    String? endDate,
    bool isCurrent = false,
    String? description,
  });

  /// Deletes a work-experience entry.
  Future<void> deleteExperience(String experienceId);
}
