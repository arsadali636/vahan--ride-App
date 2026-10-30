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
      doctorCount: _parseInt(stats['doctors']),
      hospitalCount: _parseInt(stats['hospitals']),
      jobCount: _parseInt(stats['jobs']),
      urgentJobs: (json['urgent_jobs'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => UrgentJobModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      suggestedDoctors: (json['suggested_doctors'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => SuggestedDoctorModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      unreadMessages: _parseInt(json['unread_messages']),
      unreadNotifications: _parseInt(json['unread_notifications']),
      pendingConnections: _parseInt(json['pending_connections']),
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
