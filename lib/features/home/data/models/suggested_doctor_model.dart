import 'package:equatable/equatable.dart';

import '../../domain/entities/suggested_doctor.dart';

/// Wire-format model for a suggested doctor entry.
class SuggestedDoctorModel extends Equatable {
  final String id;
  final String fullName;
  final String headline;
  final String? photo;
  final String initials;
  final String color;
  final Map<String, dynamic> location;
  final int experienceYears;
  final String verificationStatus;
  final String connectionStatus;
  final String? connectionId;
  final String? connectionDirection;

  const SuggestedDoctorModel({
    required this.id,
    required this.fullName,
    required this.headline,
    this.photo,
    required this.initials,
    required this.color,
    required this.location,
    required this.experienceYears,
    required this.verificationStatus,
    required this.connectionStatus,
    this.connectionId,
    this.connectionDirection,
  });

  factory SuggestedDoctorModel.fromJson(Map<String, dynamic> json) {
    return SuggestedDoctorModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      photo: json['photo'] as String?,
      initials: json['initials'] as String? ?? '',
      color: json['color'] as String? ?? '',
      location: json['location'] is Map
          ? Map<String, dynamic>.from(json['location'] as Map)
          : const {},
      experienceYears: _parseInt(json['experience_years']),
      verificationStatus: json['verification_status'] as String? ?? '',
      connectionStatus: json['connection_status'] as String? ?? '',
      connectionId: json['connection_id'] as String?,
      connectionDirection: json['connection_direction'] as String?,
    );
  }

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ??
          double.tryParse(value)?.toInt() ??
          defaultValue;
    }
    return defaultValue;
  }

  SuggestedDoctor toEntity() {
    return SuggestedDoctor(
      id: id,
      fullName: fullName,
      headline: headline,
      photo: photo,
      initials: initials,
      color: color,
      location: location,
      experienceYears: experienceYears,
      verificationStatus: verificationStatus,
      connectionStatus: connectionStatus,
      connectionId: connectionId,
      connectionDirection: connectionDirection,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    headline,
    photo,
    initials,
    color,
    location,
    experienceYears,
    verificationStatus,
    connectionStatus,
    connectionId,
    connectionDirection,
  ];
}
