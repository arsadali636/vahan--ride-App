import 'package:equatable/equatable.dart';

import '../../domain/entities/location.dart';
import 'location_model.dart';

/// Request body for `POST /api/v1/doctors/profile/`.
///
/// Matches the backend `DoctorProfileCreate` schema. Optional fields are
/// omitted from the payload when null.
class DoctorProfileCreateModel extends Equatable {
  final String firstName;
  final String lastName;
  final String? headline;
  final String? about;
  final String? primarySpecializationId;
  final List<String>? clinicalInterests;
  final Location? professionalLocation;
  final double? experienceYears;

  const DoctorProfileCreateModel({
    required this.firstName,
    required this.lastName,
    this.headline,
    this.about,
    this.primarySpecializationId,
    this.clinicalInterests,
    this.professionalLocation,
    this.experienceYears,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      if (headline != null) 'headline': headline,
      if (about != null) 'about': about,
      if (primarySpecializationId != null)
        'primary_specialization_id': primarySpecializationId,
      if (clinicalInterests != null) 'clinical_interests': clinicalInterests,
      if (professionalLocation != null)
        'professional_location': LocationModel.fromEntity(professionalLocation!).toJson(),
      if (experienceYears != null) 'experience_years': experienceYears,
    };
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        headline,
        about,
        primarySpecializationId,
        clinicalInterests,
        professionalLocation,
        experienceYears,
      ];
}
