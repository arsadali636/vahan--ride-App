import 'package:equatable/equatable.dart';

import '../../../professional_identity/data/models/location_model.dart';
import '../../../professional_identity/domain/entities/doctor_verification_status.dart';
import '../../../professional_identity/domain/entities/location.dart';
import '../../domain/entities/doctor_search_result.dart';

/// A single item inside the `results` array of the search endpoint.
///
/// NOTE — API contract gap: the OpenAPI response schema for
/// `GET /api/v1/doctors/search/` is undocumented (`schema: {}`), and the live
/// backend currently returns an empty `results` list, so the item shape cannot
/// be captured end-to-end. This model mirrors the observed public profile /
/// doctor profile response fields (the same backend serializer family) and
/// parses every field defensively so it degrades gracefully if the backend
/// later returns a materially different shape. Revisit once the backend
/// documents the schema.
class DoctorSearchResultModel extends Equatable {
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

  const DoctorSearchResultModel({
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

  factory DoctorSearchResultModel.fromJson(Map<String, dynamic> json) {
    return DoctorSearchResultModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      headline: json['headline'] as String?,
      photoFileId: json['photo_file_id'] as String?,
      primarySpecializationId: json['primary_specialization_id'] as String?,
      professionalLocation:
          LocationModel.fromMapOrNull(json['professional_location']),
      experienceYears: (json['experience_years'] as num? ?? 0).toDouble(),
      openToOpportunities: json['open_to_opportunities'] as bool? ?? false,
      verificationStatus: DoctorVerificationStatus.fromWire(
        json['verification_status'] as String?,
      ),
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  DoctorSearchResult toEntity() {
    return DoctorSearchResult(
      id: id,
      fullName: fullName,
      firstName: firstName,
      lastName: lastName,
      headline: headline,
      photoFileId: photoFileId,
      primarySpecializationId: primarySpecializationId,
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
        photoFileId,
        primarySpecializationId,
        professionalLocation,
        experienceYears,
        openToOpportunities,
        verificationStatus,
        isVerified,
      ];
}
