import 'package:equatable/equatable.dart';

import '../../domain/entities/doctor_experience.dart';

/// Wire model for a work-experience record.
///
/// [fromJson] tolerates both the full list shape
/// (`{id, role, hospital_name, location, start_date, end_date, is_current}`)
/// and the trimmed shape returned by
/// `POST /api/v1/doctors/profile/me/experiences/`
/// (`{id, role, hospital_name, is_current}`).
class DoctorExperienceModel extends Equatable {
  final String? id;
  final String role;
  final String hospitalName;
  final String? location;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;

  const DoctorExperienceModel({
    this.id,
    required this.role,
    required this.hospitalName,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
  });

  factory DoctorExperienceModel.fromJson(Map<String, dynamic> json) {
    return DoctorExperienceModel(
      id: json['id'] as String?,
      role: json['role'] as String? ?? '',
      hospitalName: json['hospital_name'] as String? ?? '',
      location: json['location'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      isCurrent: json['is_current'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  /// Builds the `DoctorExperienceCreate` request body.
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'hospital_name': hospitalName,
      if (location != null) 'location': location,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'is_current': isCurrent,
      if (description != null) 'description': description,
    };
  }

  DoctorExperience toEntity() {
    return DoctorExperience(
      id: id,
      role: role,
      hospitalName: hospitalName,
      location: location,
      startDate: startDate,
      endDate: endDate,
      isCurrent: isCurrent,
      description: description,
    );
  }

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
