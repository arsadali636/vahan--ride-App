import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/features/home/data/models/home_response_model.dart';
import 'package:doc_connect_app/features/home/data/models/suggested_doctor_model.dart';
import 'package:doc_connect_app/features/home/data/models/urgent_job_model.dart';

void main() {
  group('UrgentJobModel numeric parsing', () {
    test('parses integer values correctly', () {
      final model = UrgentJobModel.fromJson({
        'id': 'job-1',
        'title': 'Cardiologist',
        'hospital_name': 'City Hospital',
        'job_type': 'FULL_TIME',
        'job_type_display': 'Full Time',
        'salary_min': 50000,
        'salary_max': 90000,
        'experience_min_years': 4,
      });

      expect(model.salaryMin, 50000);
      expect(model.salaryMax, 90000);
      expect(model.experienceMinYears, 4);
    });

    test('parses floating-point numbers without throwing TypeError', () {
      final model = UrgentJobModel.fromJson({
        'id': 'job-2',
        'title': 'Surgeon',
        'hospital_name': 'Metro Clinic',
        'job_type': 'PART_TIME',
        'salary_min': 50000.0,
        'salary_max': 95000.5,
        'experience_min_years': 5.0,
      });

      expect(model.salaryMin, 50000);
      expect(model.salaryMax, 95000);
      expect(model.experienceMinYears, 5);
    });

    test('parses numeric string values safely', () {
      final model = UrgentJobModel.fromJson({
        'id': 'job-3',
        'title': 'Physician',
        'hospital_name': 'Care Hospital',
        'salary_min': '60000',
        'salary_max': '120000',
        'experience_min_years': '2',
      });

      expect(model.salaryMin, 60000);
      expect(model.salaryMax, 120000);
      expect(model.experienceMinYears, 2);
    });

    test('defaults to 0 for null or missing numeric values', () {
      final model = UrgentJobModel.fromJson({
        'id': 'job-4',
        'title': 'Resident',
        'salary_min': null,
        'salary_max': null,
        'experience_min_years': null,
      });

      expect(model.salaryMin, 0);
      expect(model.salaryMax, 0);
      expect(model.experienceMinYears, 0);
    });
  });

  group('SuggestedDoctorModel numeric parsing', () {
    test('parses integer experience correctly', () {
      final model = SuggestedDoctorModel.fromJson({
        'id': 'doc-1',
        'full_name': 'Dr. Alice',
        'experience_years': 8,
      });

      expect(model.experienceYears, 8);
    });

    test('parses floating-point experience without throwing TypeError', () {
      final model = SuggestedDoctorModel.fromJson({
        'id': 'doc-2',
        'full_name': 'Dr. Bob',
        'experience_years': 12.5,
      });

      expect(model.experienceYears, 12);
    });

    test('parses string experience safely', () {
      final model = SuggestedDoctorModel.fromJson({
        'id': 'doc-3',
        'full_name': 'Dr. Charlie',
        'experience_years': '15',
      });

      expect(model.experienceYears, 15);
    });

    test('defaults to 0 for null or missing experience', () {
      final model = SuggestedDoctorModel.fromJson({
        'id': 'doc-4',
        'full_name': 'Dr. Dana',
        'experience_years': null,
      });

      expect(model.experienceYears, 0);
    });
  });

  group('HomeResponseModel numeric parsing', () {
    test('parses mixed numeric formats in stats and counts safely', () {
      final model = HomeResponseModel.fromJson({
        'stats': {'doctors': '150', 'hospitals': 45.0, 'jobs': 30},
        'unread_messages': '5',
        'unread_notifications': 10.0,
        'pending_connections': 2,
      });

      expect(model.doctorCount, 150);
      expect(model.hospitalCount, 45);
      expect(model.jobCount, 30);
      expect(model.unreadMessages, 5);
      expect(model.unreadNotifications, 10);
      expect(model.pendingConnections, 2);
    });
  });
}
