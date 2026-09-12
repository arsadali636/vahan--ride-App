import '../entities/doctor_profile.dart';
import '../repositories/doctor_profile_repository.dart';

class GetDoctorProfile {
  final DoctorProfileRepository repository;

  GetDoctorProfile(this.repository);

  Future<DoctorProfile> call() {
    return repository.getMyProfile();
  }
}
