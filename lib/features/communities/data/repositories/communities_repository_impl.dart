import '../../domain/entities/communities_entity.dart';
import '../../domain/repositories/communities_repository.dart';
import '../datasources/communities_remote_data_source.dart';

class CommunitiesRepositoryImpl implements CommunitiesRepository {
  final CommunitiesRemoteDataSource remoteDataSource;

  CommunitiesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CommunitiesEntity?> getCommunitiesData() async {
    // TODO: Implement repository logic
    return null;
  }
}
