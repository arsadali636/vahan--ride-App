import '../entities/doctor_profile.dart';
import '../entities/location.dart';
import '../repositories/doctor_profile_repository.dart';

class UpdateDoctorProfile {
  final DoctorProfileRepository repository;

  UpdateDoctorProfile(this.repository);

  Future<DoctorProfile> call({
    String? firstName,
    String? lastName,
    String? headline,
    String? about,
    String? primarySpecializationId,
    List<String>? clinicalInterests,
    Location? professionalLocation,
    double? experienceYears,
    bool? openToOpportunities,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      headline: headline,
      about: about,
      primarySpecializationId: primarySpecializationId,
      clinicalInterests: clinicalInterests,
      professionalLocation: professionalLocation,
      experienceYears: experienceYears,
      openToOpportunities: openToOpportunities,
    );
  }
}
