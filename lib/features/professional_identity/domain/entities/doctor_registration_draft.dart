import 'package:equatable/equatable.dart';

/// User-edited snapshot of a registration before it is sent to the backend.
class DoctorRegistrationDraft extends Equatable {
  final String councilId;
  final String registrationNumber;
  final int registrationYear;
  final bool isPrimary;

  const DoctorRegistrationDraft({
    required this.councilId,
    required this.registrationNumber,
    required this.registrationYear,
    this.isPrimary = false,
  });

  @override
  List<Object?> get props => [councilId, registrationNumber, registrationYear, isPrimary];
}
