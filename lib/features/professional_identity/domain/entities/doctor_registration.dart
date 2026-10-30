import 'package:equatable/equatable.dart';

/// A medical council registration, one of the profile sub-resources.
///
/// Mirrors the `DoctorRegistration` records exposed by
/// `GET /api/v1/doctors/profile/me/registrations/`. The `id` is assigned by
/// the backend and is absent when constructing a new entry.
class DoctorRegistration extends Equatable {
  final String? id;
  final String councilId;
  final String registrationNumber;
  final int registrationYear;
  final bool isPrimary;

  const DoctorRegistration({
    this.id,
    required this.councilId,
    required this.registrationNumber,
    required this.registrationYear,
    this.isPrimary = false,
  });

  @override
  List<Object?> get props => [
    id,
    councilId,
    registrationNumber,
    registrationYear,
    isPrimary,
  ];
}
