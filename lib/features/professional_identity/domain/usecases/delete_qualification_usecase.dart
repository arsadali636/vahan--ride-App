import '../repositories/doctor_profile_repository.dart';

/// Deletes a qualification from the caller's profile.
class DeleteQualification {
  final DoctorProfileRepository repository;

  DeleteQualification(this.repository);

  Future<void> call(String qualificationId) {
    return repository.deleteQualification(qualificationId);
  }
}
