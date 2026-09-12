import 'package:equatable/equatable.dart';

import 'doctor_verification_status.dart';
import 'location.dart';

/// A doctor's professional profile.
///
/// Mirrors the `DoctorProfileResponse` shape returned by
/// `GET/PATCH /api/v1/doctors/profile/me/` and
/// `POST /api/v1/doctors/profile/`.
class DoctorProfile extends Equatable {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? photoFileId;
  final String? headline;
  final String? about;
  final String? primarySpecializationId;
  final List<String> clinicalInterests;
  final Location? professionalLocation;
  final double experienceYears;
  final bool openToOpportunities;
  final DoctorVerificationStatus verificationStatus;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DoctorProfile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.photoFileId,
    this.headline,
    this.about,
    this.primarySpecializationId,
    this.clinicalInterests = const [],
    this.professionalLocation,
    this.experienceYears = 0,
    this.openToOpportunities = false,
    this.verificationStatus = DoctorVerificationStatus.unverified,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  String get displayName => fullName.isNotEmpty ? fullName : '$firstName $lastName'.trim();

  DoctorProfile copyWith({
    String? firstName,
    String? lastName,
    String? fullName,
    String? photoFileId,
    String? headline,
    String? about,
    String? primarySpecializationId,
    List<String>? clinicalInterests,
    Location? professionalLocation,
    double? experienceYears,
    bool? openToOpportunities,
    DoctorVerificationStatus? verificationStatus,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorProfile(
      id: id,
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      photoFileId: photoFileId ?? this.photoFileId,
      headline: headline ?? this.headline,
      about: about ?? this.about,
      primarySpecializationId: primarySpecializationId ?? this.primarySpecializationId,
      clinicalInterests: clinicalInterests ?? this.clinicalInterests,
      professionalLocation: professionalLocation ?? this.professionalLocation,
      experienceYears: experienceYears ?? this.experienceYears,
      openToOpportunities: openToOpportunities ?? this.openToOpportunities,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        fullName,
        photoFileId,
        headline,
        about,
        primarySpecializationId,
        clinicalInterests,
        professionalLocation,
        experienceYears,
        openToOpportunities,
        verificationStatus,
        isVerified,
        createdAt,
        updatedAt,
      ];
}
