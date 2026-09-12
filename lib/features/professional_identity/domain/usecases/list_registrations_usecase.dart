import '../entities/doctor_registration.dart';
import '../repositories/doctor_profile_repository.dart';

/// Lists the caller's medical registrations.
class ListRegistrations {
  final DoctorProfileRepository repository;

  ListRegistrations(this.repository);

  Future<List<DoctorRegistration>> call() {
    return repository.listRegistrations();
  }
}
