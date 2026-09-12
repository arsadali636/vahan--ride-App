import '../entities/doctor_experience.dart';
import '../repositories/doctor_profile_repository.dart';

/// Lists the caller's work-experience entries.
class ListExperiences {
  final DoctorProfileRepository repository;

  ListExperiences(this.repository);

  Future<List<DoctorExperience>> call() {
    return repository.listExperiences();
  }
}
