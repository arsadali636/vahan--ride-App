import '../entities/doctor_profile.dart';
import '../entities/location.dart';
import '../repositories/doctor_profile_repository.dart';

class CreateDoctorProfile {
  final DoctorProfileRepository repository;

  CreateDoctorProfile(this.repository);

  Future<DoctorProfile> call({
    required String firstName,
    required String lastName,
    String? headline,
    String? about,
    String? primarySpecializationId,
    List<String>? clinicalInterests,
    Location? professionalLocation,
    double? experienceYears,
  }) {
    return repository.createProfile(
      firstName: firstName,
      lastName: lastName,
      headline: headline,
      about: about,
      primarySpecializationId: primarySpecializationId,
      clinicalInterests: clinicalInterests,
      professionalLocation: professionalLocation,
      experienceYears: experienceYears,
    );
  }
}
