import '../entities/reporting_entity.dart';
import '../repositories/reporting_repository.dart';

class GetReportingUseCase {
  final ReportingRepository repository;

  GetReportingUseCase(this.repository);

  Future<ReportingEntity?> call() async {
    return await repository.getReportingData();
  }
}
