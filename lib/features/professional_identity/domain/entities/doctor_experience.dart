import 'package:equatable/equatable.dart';

/// A work-experience entry, one of the profile sub-resources.
///
/// Mirrors the `DoctorExperience` records returned by
/// `GET /api/v1/doctors/profile/me/experiences/`. Dates are kept as raw
/// `yyyy-MM-dd` strings (as the backend serializes them) so this model makes
/// no assumption about a specific format.
class DoctorExperience extends Equatable {
  final String? id;
  final String role;
  final String hospitalName;
  final String? location;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;

  const DoctorExperience({
    this.id,
    required this.role,
    required this.hospitalName,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        role,
        hospitalName,
        location,
        startDate,
        endDate,
        isCurrent,
        description,
      ];
}
