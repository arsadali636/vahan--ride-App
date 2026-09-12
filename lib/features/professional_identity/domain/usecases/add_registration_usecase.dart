import '../entities/doctor_registration.dart';
import '../repositories/doctor_profile_repository.dart';

/// Adds a registration to the caller's profile.
class AddRegistration {
  final DoctorProfileRepository repository;

  AddRegistration(this.repository);

  Future<DoctorRegistration> call({
    required String councilId,
    required String registrationNumber,
    required int registrationYear,
    bool isPrimary = false,
  }) {
    return repository.addRegistration(
      councilId: councilId,
      registrationNumber: registrationNumber,
      registrationYear: registrationYear,
      isPrimary: isPrimary,
    );
  }
}
