import 'package:equatable/equatable.dart';

import '../../domain/entities/doctor_qualification.dart';

/// Wire model for a qualification record.
///
/// [fromJson] tolerates both the full list shape
/// (`{id, degree, institution, year, specialization}`) and the trimmed shape
/// returned by `POST /api/v1/doctors/profile/me/qualifications/`
/// (`{id, degree, institution, year}`).
class DoctorQualificationModel extends Equatable {
  final String? id;
  final String degree;
  final String institution;
  final int year;
  final String? specialization;

  const DoctorQualificationModel({
    this.id,
    required this.degree,
    required this.institution,
    required this.year,
    this.specialization,
  });

  factory DoctorQualificationModel.fromJson(Map<String, dynamic> json) {
    return DoctorQualificationModel(
      id: json['id'] as String?,
      degree: json['degree'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      year: (json['year'] as num? ?? 0).toInt(),
      specialization: json['specialization'] as String?,
    );
  }

  /// Builds the `DoctorQualificationCreate` request body.
  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'institution': institution,
      'year': year,
      if (specialization != null) 'specialization': specialization,
    };
  }

  DoctorQualification toEntity() {
    return DoctorQualification(
      id: id,
      degree: degree,
      institution: institution,
      year: year,
      specialization: specialization,
    );
  }

  @override
  List<Object?> get props => [id, degree, institution, year, specialization];
}
