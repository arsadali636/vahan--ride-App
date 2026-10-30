import 'package:doc_connect_app/features/home/domain/entities/home_data.dart';
import 'package:doc_connect_app/features/home/domain/entities/suggested_doctor.dart';
import 'package:doc_connect_app/features/home/domain/entities/urgent_job.dart';
import 'package:doc_connect_app/features/home/domain/repositories/home_repository.dart';

class FakeHomeRepository implements HomeRepository {
  HomeData homeData = const HomeData(
    doctorCount: 120,
    hospitalCount: 15,
    jobCount: 8,
    urgentJobs: [
      UrgentJob(
        id: 'job-1',
        title: 'Emergency Physician',
        hospitalName: 'Apollo Hospital',
        jobType: 'full_time',
        jobTypeDisplay: 'Full Time',
        location: {'city': 'Mumbai'},
        salaryMin: 150000,
        salaryMax: 200000,
        salaryVisibility: 'public',
        experienceMinYears: 3,
        isUrgent: true,
        postedAt: '2026-03-30T08:00:00Z',
      ),
    ],
    suggestedDoctors: [
      SuggestedDoctor(
        id: 'doc-1',
        fullName: 'Dr. Rahul Mehta',
        headline: 'Senior Cardiologist',
        initials: 'RM',
        color: '#378FE9',
        location: {'city': 'Delhi'},
        experienceYears: 10,
        verificationStatus: 'verified',
        connectionStatus: 'none',
      ),
    ],
    unreadMessages: 2,
    unreadNotifications: 5,
    pendingConnections: 1,
  );

  int getHomeDataCalls = 0;

  @override
  Future<HomeData> getHomeData() async {
    getHomeDataCalls++;
    return homeData;
  }
}
