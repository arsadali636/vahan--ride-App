import 'package:equatable/equatable.dart';

import '../../../professional_identity/domain/entities/doctor_verification_status.dart';
import '../../../professional_identity/domain/entities/location.dart';

/// A doctor's profile as seen through the public discovery endpoint.
///
/// `GET /api/v1/doctors/profile/{doctor_id}/` is the only source of truth for
/// this screen. The entity deliberately does not carry private fields (phone,
/// personal email, expected compensation, detailed availability) even if a
/// locally cached object happened to contain them — privacy requirements take
/// priority over convenience.
class PublicDoctorProfile extends Equatable {
  final String id;
  final String fullName;
  final String firstName;
  final String lastName;
  final String? headline;
  final String? about;
  final String? photoFileId;
  final String? primarySpecializationId;
  final List<String> clinicalInterests;
  final Location? professionalLocation;
  final double experienceYears;
  final bool openToOpportunities;
  final DoctorVerificationStatus verificationStatus;
  final bool isVerified;

  const PublicDoctorProfile({
    required this.id,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    this.headline,
    this.about,
    this.photoFileId,
    this.primarySpecializationId,
    this.clinicalInterests = const [],
    this.professionalLocation,
    this.experienceYears = 0,
    this.openToOpportunities = false,
    this.verificationStatus = DoctorVerificationStatus.unverified,
    this.isVerified = false,
  });

  String get displayName =>
      fullName.isNotEmpty ? fullName : '$firstName $lastName'.trim();

  /// Compact `City, State` label for the profile header, when supplied.
  String? get locationLabel => professionalLocation?.label;

  @override
  List<Object?> get props => [
    id,
    fullName,
    firstName,
    lastName,
    headline,
    about,
    photoFileId,
    primarySpecializationId,
    clinicalInterests,
    professionalLocation,
    experienceYears,
    openToOpportunities,
    verificationStatus,
    isVerified,
  ];
}
