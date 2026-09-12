import '../entities/doctor_qualification.dart';
import '../repositories/doctor_profile_repository.dart';

/// Lists the caller's qualifications.
class ListQualifications {
  final DoctorProfileRepository repository;

  ListQualifications(this.repository);

  Future<List<DoctorQualification>> call() {
    return repository.listQualifications();
  }
}
