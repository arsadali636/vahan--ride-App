import 'package:equatable/equatable.dart';

/// A doctor's qualification (degree), one of the profile sub-resources.
///
/// Mirrors the `DoctorQualification` records returned by
/// `GET /api/v1/doctors/profile/me/qualifications/`. The `id` is assigned by
/// the backend and is absent when constructing a new entry.
class DoctorQualification extends Equatable {
  final String? id;
  final String degree;
  final String institution;
  final int year;
  final String? specialization;

  const DoctorQualification({
    this.id,
    required this.degree,
    required this.institution,
    required this.year,
    this.specialization,
  });

  @override
  List<Object?> get props => [id, degree, institution, year, specialization];
}
