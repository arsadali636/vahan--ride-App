import '../entities/reporting_entity.dart';

abstract class ReportingRepository {
  Future<ReportingEntity?> getReportingData();
}
