import 'package:equatable/equatable.dart';

import '../../../professional_identity/data/models/location_model.dart';
import '../../../professional_identity/domain/entities/doctor_verification_status.dart';
import '../../../professional_identity/domain/entities/location.dart';
import '../../domain/entities/public_doctor_profile.dart';

/// Response body for `GET /api/v1/doctors/profile/{doctor_id}/`.
///
/// Live-probed shape is identical to the caller's own profile response and
/// contains only publicly visible fields (no phone, personal email,
/// compensation or availability). The model maps exactly the fields the
/// backend returns.
class PublicDoctorProfileModel extends Equatable {
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

  const PublicDoctorProfileModel({
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

  factory PublicDoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return PublicDoctorProfileModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      headline: json['headline'] as String?,
      about: json['about'] as String?,
      photoFileId: json['photo_file_id'] as String?,
      primarySpecializationId: json['primary_specialization_id'] as String?,
      clinicalInterests:
          (json['clinical_interests'] as List? ?? const [])
              .map((e) => e as String)
              .toList(),
      professionalLocation:
          LocationModel.fromMapOrNull(json['professional_location']),
      experienceYears:
          (json['experience_years'] as num? ?? 0).toDouble(),
      openToOpportunities: json['open_to_opportunities'] as bool? ?? false,
      verificationStatus: DoctorVerificationStatus.fromWire(
        json['verification_status'] as String?,
      ),
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  PublicDoctorProfile toEntity() {
    return PublicDoctorProfile(
      id: id,
      fullName: fullName,
      firstName: firstName,
      lastName: lastName,
      headline: headline,
      about: about,
      photoFileId: photoFileId,
      primarySpecializationId: primarySpecializationId,
      clinicalInterests: clinicalInterests,
      professionalLocation: professionalLocation,
      experienceYears: experienceYears,
      openToOpportunities: openToOpportunities,
      verificationStatus: verificationStatus,
      isVerified: isVerified,
    );
  }

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
