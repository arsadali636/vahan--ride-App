import 'package:equatable/equatable.dart';

import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/doctor_verification_status.dart';
import '../../domain/entities/location.dart';
import 'location_model.dart';

/// Response body for the doctor profile endpoints.
///
/// Matches the `DoctorProfileResponse` shape returned by
/// `POST /api/v1/doctors/profile/`, `GET /api/v1/doctors/profile/me/` and
/// `PATCH /api/v1/doctors/profile/me/`.
class DoctorProfileResponseModel extends Equatable {
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

  const DoctorProfileResponseModel({
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

  factory DoctorProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileResponseModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      photoFileId: json['photo_file_id'] as String?,
      headline: json['headline'] as String?,
      about: json['about'] as String?,
      primarySpecializationId: json['primary_specialization_id'] as String?,
      clinicalInterests:
          (json['clinical_interests'] as List? ?? const [])
              .map((e) => e as String)
              .toList(),
      professionalLocation: LocationModel.fromMapOrNull(
        json['professional_location'],
      ),
      experienceYears:
          (json['experience_years'] as num? ?? 0).toDouble(),
      openToOpportunities: json['open_to_opportunities'] as bool? ?? false,
      verificationStatus: DoctorVerificationStatus.fromWire(
        json['verification_status'] as String?,
      ),
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  DoctorProfile toEntity() {
    return DoctorProfile(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      photoFileId: photoFileId,
      headline: headline,
      about: about,
      primarySpecializationId: primarySpecializationId,
      clinicalInterests: clinicalInterests,
      professionalLocation: professionalLocation,
      experienceYears: experienceYears,
      openToOpportunities: openToOpportunities,
      verificationStatus: verificationStatus,
      isVerified: isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
