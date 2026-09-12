import '../entities/doctor_qualification.dart';
import '../repositories/doctor_profile_repository.dart';

/// Adds a qualification to the caller's profile.
class AddQualification {
  final DoctorProfileRepository repository;

  AddQualification(this.repository);

  Future<DoctorQualification> call({
    required String degree,
    required String institution,
    required int year,
    String? specialization,
  }) {
    return repository.addQualification(
      degree: degree,
      institution: institution,
      year: year,
      specialization: specialization,
    );
  }
}
