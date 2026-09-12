import 'package:equatable/equatable.dart';

import '../../domain/entities/doctor_registration.dart';

/// Wire model for a medical registration record.
///
/// The live backend currently returns `500` for
/// `POST /api/v1/doctors/profile/me/registrations/` and `[]` for the list, so
/// [fromJson] is written defensively against the contract fields
/// (`id`, `council_id`, `registration_number`, `registration_year`,
/// `is_primary`) without assuming any are present.
class DoctorRegistrationModel extends Equatable {
  final String? id;
  final String councilId;
  final String registrationNumber;
  final int registrationYear;
  final bool isPrimary;

  const DoctorRegistrationModel({
    this.id,
    required this.councilId,
    required this.registrationNumber,
    required this.registrationYear,
    this.isPrimary = false,
  });

  factory DoctorRegistrationModel.fromJson(Map<String, dynamic> json) {
    return DoctorRegistrationModel(
      id: json['id'] as String?,
      councilId: json['council_id'] as String? ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      registrationYear: (json['registration_year'] as num? ?? 0).toInt(),
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  /// Builds the `DoctorRegistrationCreate` request body.
  Map<String, dynamic> toJson() {
    return {
      'council_id': councilId,
      'registration_number': registrationNumber,
      'registration_year': registrationYear,
      'is_primary': isPrimary,
    };
  }

  DoctorRegistration toEntity() {
    return DoctorRegistration(
      id: id,
      councilId: councilId,
      registrationNumber: registrationNumber,
      registrationYear: registrationYear,
      isPrimary: isPrimary,
    );
  }

  @override
  List<Object?> get props => [
        id,
        councilId,
        registrationNumber,
        registrationYear,
        isPrimary,
      ];
}
