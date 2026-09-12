import '../entities/doctor_experience.dart';
import '../repositories/doctor_profile_repository.dart';

/// Adds a work-experience entry to the caller's profile.
class AddExperience {
  final DoctorProfileRepository repository;

  AddExperience(this.repository);

  Future<DoctorExperience> call({
    required String role,
    required String hospitalName,
    String? location,
    String? startDate,
    String? endDate,
    bool isCurrent = false,
    String? description,
  }) {
    return repository.addExperience(
      role: role,
      hospitalName: hospitalName,
      location: location,
      startDate: startDate,
      endDate: endDate,
      isCurrent: isCurrent,
      description: description,
    );
  }
}
