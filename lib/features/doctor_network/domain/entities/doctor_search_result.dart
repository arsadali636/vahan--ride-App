import 'package:equatable/equatable.dart';

import '../../../professional_identity/domain/entities/doctor_verification_status.dart';
import '../../../professional_identity/domain/entities/location.dart';

/// A compact, publicly visible doctor entry shown in discovery search results.
///
/// Only publicly visible information is exposed here — never phone numbers,
/// email addresses, compensation or availability. Verification status is
/// reflected exactly as the backend reports it and is never computed locally.
class DoctorSearchResult extends Equatable {
  final String id;
  final String fullName;
  final String firstName;
  final String lastName;
  final String? headline;
  final String? photoFileId;
  final String? primarySpecializationId;
  final Location? professionalLocation;
  final double experienceYears;
  final bool openToOpportunities;
  final DoctorVerificationStatus verificationStatus;
  final bool isVerified;

  const DoctorSearchResult({
    required this.id,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    this.headline,
    this.photoFileId,
    this.primarySpecializationId,
    this.professionalLocation,
    this.experienceYears = 0,
    this.openToOpportunities = false,
    this.verificationStatus = DoctorVerificationStatus.unverified,
    this.isVerified = false,
  });

  String get displayName =>
      fullName.isNotEmpty ? fullName : '$firstName $lastName'.trim();

  /// Compact `City, State` label for result rows, when the backend supplies it.
  String? get locationLabel => professionalLocation?.label;

  @override
  List<Object?> get props => [
    id,
    fullName,
    firstName,
    lastName,
    headline,
    photoFileId,
    primarySpecializationId,
    professionalLocation,
    experienceYears,
    openToOpportunities,
    verificationStatus,
    isVerified,
  ];
}
