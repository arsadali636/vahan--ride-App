import 'package:equatable/equatable.dart';

/// User-edited snapshot of a qualification before it is sent to the backend.
class DoctorQualificationDraft extends Equatable {
  final String degree;
  final String institution;
  final int year;
  final String? specialization;

  const DoctorQualificationDraft({
    required this.degree,
    required this.institution,
    required this.year,
    this.specialization,
  });

  @override
  List<Object?> get props => [degree, institution, year, specialization];
}
