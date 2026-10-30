import 'package:equatable/equatable.dart';

/// User-edited snapshot of a work-experience entry before it is sent to the
/// backend. Dates are raw `yyyy-MM-dd` strings.
class DoctorExperienceDraft extends Equatable {
  final String role;
  final String hospitalName;
  final String? location;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;

  const DoctorExperienceDraft({
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
    role,
    hospitalName,
    location,
    startDate,
    endDate,
    isCurrent,
    description,
  ];
}
