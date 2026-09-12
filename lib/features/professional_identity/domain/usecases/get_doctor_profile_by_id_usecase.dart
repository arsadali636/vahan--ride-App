import '../entities/doctor_profile.dart';
import '../repositories/doctor_profile_repository.dart';

/// Reads a public doctor profile by id.
class GetDoctorProfileById {
  final DoctorProfileRepository repository;

  GetDoctorProfileById(this.repository);

  Future<DoctorProfile> call(String doctorId) {
    return repository.getDoctorProfileById(doctorId);
  }
}
