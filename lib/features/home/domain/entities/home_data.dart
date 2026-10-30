import 'package:equatable/equatable.dart';

import 'suggested_doctor.dart';
import 'urgent_job.dart';

/// Aggregate home dashboard data returned by `GET /api/v1/feed/home/`.
class HomeData extends Equatable {
  final int doctorCount;
  final int hospitalCount;
  final int jobCount;
  final List<UrgentJob> urgentJobs;
  final List<SuggestedDoctor> suggestedDoctors;
  final int unreadMessages;
  final int unreadNotifications;
  final int pendingConnections;

  const HomeData({
    required this.doctorCount,
    required this.hospitalCount,
    required this.jobCount,
    required this.urgentJobs,
    required this.suggestedDoctors,
    required this.unreadMessages,
    required this.unreadNotifications,
    required this.pendingConnections,
  });

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
