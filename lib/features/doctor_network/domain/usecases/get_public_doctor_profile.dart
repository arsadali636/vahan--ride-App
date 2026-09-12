import '../entities/public_doctor_profile.dart';
import '../repositories/doctor_network_repository.dart';

/// Fetches a doctor's public profile for the discovery detail screen.
class GetPublicDoctorProfile {
  final DoctorNetworkRepository repository;

  GetPublicDoctorProfile(this.repository);

  Future<PublicDoctorProfile> call(String doctorId) {
    return repository.getDoctorProfile(doctorId);
  }
}
