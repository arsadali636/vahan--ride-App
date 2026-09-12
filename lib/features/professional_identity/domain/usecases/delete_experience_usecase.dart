import '../repositories/doctor_profile_repository.dart';

/// Deletes a work-experience entry from the caller's profile.
class DeleteExperience {
  final DoctorProfileRepository repository;

  DeleteExperience(this.repository);

  Future<void> call(String experienceId) {
    return repository.deleteExperience(experienceId);
  }
}
