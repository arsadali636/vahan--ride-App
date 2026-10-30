import 'package:equatable/equatable.dart';

import '../../domain/entities/urgent_job.dart';

/// Wire-format model for a single urgent job listing.
class UrgentJobModel extends Equatable {
  final String id;
  final String title;
  final String hospitalName;
  final String? hospitalLogo;
  final String jobType;
  final String jobTypeDisplay;
  final Map<String, dynamic> location;
  final int salaryMin;
  final int salaryMax;
  final String salaryVisibility;
  final int experienceMinYears;
  final bool isUrgent;
  final String postedAt;

  const UrgentJobModel({
    required this.id,
    required this.title,
    required this.hospitalName,
    this.hospitalLogo,
    required this.jobType,
    required this.jobTypeDisplay,
    required this.location,
    required this.salaryMin,
    required this.salaryMax,
    required this.salaryVisibility,
    required this.experienceMinYears,
    required this.isUrgent,
    required this.postedAt,
  });

  factory UrgentJobModel.fromJson(Map<String, dynamic> json) {
    return UrgentJobModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      hospitalName: json['hospital_name'] as String? ?? '',
      hospitalLogo: json['hospital_logo'] as String?,
      jobType: json['job_type'] as String? ?? '',
      jobTypeDisplay: json['job_type_display'] as String? ?? '',
      location: json['location'] is Map
          ? Map<String, dynamic>.from(json['location'] as Map)
          : const {},
      salaryMin: _parseInt(json['salary_min']),
      salaryMax: _parseInt(json['salary_max']),
      salaryVisibility: json['salary_visibility'] as String? ?? '',
      experienceMinYears: _parseInt(json['experience_min_years']),
      isUrgent: json['is_urgent'] as bool? ?? false,
      postedAt: json['posted_at'] as String? ?? '',
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

  UrgentJob toEntity() {
    return UrgentJob(
      id: id,
      title: title,
      hospitalName: hospitalName,
      hospitalLogo: hospitalLogo,
      jobType: jobType,
      jobTypeDisplay: jobTypeDisplay,
      location: location,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      salaryVisibility: salaryVisibility,
      experienceMinYears: experienceMinYears,
      isUrgent: isUrgent,
      postedAt: postedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    hospitalName,
    hospitalLogo,
    jobType,
    jobTypeDisplay,
    location,
    salaryMin,
    salaryMax,
    salaryVisibility,
    experienceMinYears,
    isUrgent,
    postedAt,
  ];
}
