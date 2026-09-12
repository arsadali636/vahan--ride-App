import 'package:equatable/equatable.dart';

import 'location.dart';

/// User-edited snapshot of the writable doctor profile fields.
///
/// Used by the profile completion and edit flows. Every field except
/// [firstName]/[lastName] is optional because the backend create/update
/// schemas only require those two.
class DoctorProfileDraft extends Equatable {
  final String firstName;
  final String lastName;
  final String? headline;
  final String? about;
  final String? primarySpecializationId;
  final List<String> clinicalInterests;
  final Location? location;
  final double? experienceYears;
  final bool? openToOpportunities;

  const DoctorProfileDraft({
    required this.firstName,
    required this.lastName,
    this.headline,
    this.about,
    this.primarySpecializationId,
    this.clinicalInterests = const [],
    this.location,
    this.experienceYears,
    this.openToOpportunities,
  });

  DoctorProfileDraft copyWith({
    String? firstName,
    String? lastName,
    String? headline,
    String? about,
    String? primarySpecializationId,
    List<String>? clinicalInterests,
    Location? location,
    double? experienceYears,
    bool? openToOpportunities,
  }) {
    return DoctorProfileDraft(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      headline: headline ?? this.headline,
      about: about ?? this.about,
      primarySpecializationId:
          primarySpecializationId ?? this.primarySpecializationId,
      clinicalInterests: clinicalInterests ?? this.clinicalInterests,
      location: location ?? this.location,
      experienceYears: experienceYears ?? this.experienceYears,
      openToOpportunities: openToOpportunities ?? this.openToOpportunities,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        headline,
        about,
        primarySpecializationId,
        clinicalInterests,
        location,
        experienceYears,
        openToOpportunities,
      ];
}
