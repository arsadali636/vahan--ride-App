import '../../domain/entities/applications_entity.dart';
import '../../domain/repositories/applications_repository.dart';
import '../datasources/applications_remote_data_source.dart';

class ApplicationsRepositoryImpl implements ApplicationsRepository {
  final ApplicationsRemoteDataSource remoteDataSource;

  ApplicationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApplicationsEntity?> getApplicationsData() async {
    // TODO: Implement repository logic
    return null;
  }
}
