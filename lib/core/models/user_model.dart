import 'package:equatable/equatable.dart';

import '../enums/verification_status.dart';

/// Locally cached representation of the authenticated user.
///
/// Wire keys mirror the backend profile contract (snake_case) so a profile
/// response can be cached without transformation. All fields are null-safe:
/// the exact profile shape is not finalized yet.
class UserModel extends Equatable {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImage;
  final String? professionalHeadline;
  final String? primarySpecializationId;
  final String? qualification;
  final VerificationStatus? verificationStatus;

  const UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImage,
    this.professionalHeadline,
    this.primarySpecializationId,
    this.qualification,
    this.verificationStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      profileImage: json['profile_image'] as String?,
      professionalHeadline: json['professional_headline'] as String?,
      primarySpecializationId: json['primary_specialization_id'] as String?,
      qualification: json['qualification'] as String?,
      verificationStatus: _verificationStatusFromWire(
        json['verification_status'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'profile_image': profileImage,
      'professional_headline': professionalHeadline,
      'primary_specialization_id': primarySpecializationId,
      'qualification': qualification,
      'verification_status': verificationStatus?.name,
    };
  }

  static VerificationStatus? _verificationStatusFromWire(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.toLowerCase();
    for (final status in VerificationStatus.values) {
      if (status.name == normalized) return status;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    profileImage,
    professionalHeadline,
    primarySpecializationId,
    qualification,
    verificationStatus,
  ];
}
