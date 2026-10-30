import 'package:equatable/equatable.dart';

/// A single urgent job listing from the home dashboard.
class UrgentJob extends Equatable {
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

  const UrgentJob({
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
