import 'package:equatable/equatable.dart';

import '../../domain/entities/home_data.dart';
import 'suggested_doctor_model.dart';
import 'urgent_job_model.dart';

/// Wire-format model for the home dashboard response.
///
/// Parsed from `GET /api/v1/feed/home/`.
class HomeResponseModel extends Equatable {
  final int doctorCount;
  final int hospitalCount;
  final int jobCount;
  final List<UrgentJobModel> urgentJobs;
  final List<SuggestedDoctorModel> suggestedDoctors;
  final int unreadMessages;
  final int unreadNotifications;
  final int pendingConnections;

  const HomeResponseModel({
    required this.doctorCount,
    required this.hospitalCount,
    required this.jobCount,
    required this.urgentJobs,
    required this.suggestedDoctors,
    required this.unreadMessages,
    required this.unreadNotifications,
    required this.pendingConnections,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] is Map
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : const <String, dynamic>{};

    return HomeResponseModel(
      doctorCount: stats['doctors'] as int? ?? 0,
      hospitalCount: stats['hospitals'] as int? ?? 0,
      jobCount: stats['jobs'] as int? ?? 0,
      urgentJobs: (json['urgent_jobs'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => UrgentJobModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      suggestedDoctors: (json['suggested_doctors'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => SuggestedDoctorModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      unreadMessages: json['unread_messages'] as int? ?? 0,
      unreadNotifications: json['unread_notifications'] as int? ?? 0,
      pendingConnections: json['pending_connections'] as int? ?? 0,
    );
  }

  HomeData toEntity() {
    return HomeData(
      doctorCount: doctorCount,
      hospitalCount: hospitalCount,
      jobCount: jobCount,
      urgentJobs: urgentJobs.map((e) => e.toEntity()).toList(),
      suggestedDoctors: suggestedDoctors.map((e) => e.toEntity()).toList(),
      unreadMessages: unreadMessages,
      unreadNotifications: unreadNotifications,
      pendingConnections: pendingConnections,
    );
  }

  @override
  List<Object?> get props => [
        doctorCount,
        hospitalCount,
        jobCount,
        urgentJobs,
        suggestedDoctors,
        unreadMessages,
        unreadNotifications,
        pendingConnections,
      ];
}
