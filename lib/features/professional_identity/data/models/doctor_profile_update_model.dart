import 'package:equatable/equatable.dart';

import '../../domain/entities/location.dart';
import 'location_model.dart';

/// Request body for `PATCH /api/v1/doctors/profile/me/`.
///
/// Matches the backend `DoctorProfileUpdate` schema. All fields are optional;
/// only non-null fields are sent (partial update).
class DoctorProfileUpdateModel extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? headline;
  final String? about;
  final String? primarySpecializationId;
  final List<String>? clinicalInterests;
  final Location? professionalLocation;
  final double? experienceYears;
  final bool? openToOpportunities;

  const DoctorProfileUpdateModel({
    this.firstName,
    this.lastName,
    this.headline,
    this.about,
    this.primarySpecializationId,
    this.clinicalInterests,
    this.professionalLocation,
    this.experienceYears,
    this.openToOpportunities,
  });

  Map<String, dynamic> toJson() {
    return {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (headline != null) 'headline': headline,
      if (about != null) 'about': about,
      if (primarySpecializationId != null)
        'primary_specialization_id': primarySpecializationId,
      if (clinicalInterests != null) 'clinical_interests': clinicalInterests,
      if (professionalLocation != null)
        'professional_location': LocationModel.fromEntity(
          professionalLocation!,
        ).toJson(),
      if (experienceYears != null) 'experience_years': experienceYears,
      if (openToOpportunities != null)
        'open_to_opportunities': openToOpportunities,
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
    openToOpportunities,
  ];
}
