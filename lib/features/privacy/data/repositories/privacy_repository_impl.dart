import '../../domain/entities/privacy_entity.dart';
import '../../domain/repositories/privacy_repository.dart';
import '../datasources/privacy_remote_data_source.dart';

class PrivacyRepositoryImpl implements PrivacyRepository {
  final PrivacyRemoteDataSource remoteDataSource;

  PrivacyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PrivacyEntity?> getPrivacyData() async {
    // TODO: Implement repository logic
    return null;
  }
}
