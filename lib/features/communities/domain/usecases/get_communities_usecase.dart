import '../entities/communities_entity.dart';
import '../repositories/communities_repository.dart';

class GetCommunitiesUseCase {
  final CommunitiesRepository repository;

  GetCommunitiesUseCase(this.repository);

  Future<CommunitiesEntity?> call() async {
    return await repository.getCommunitiesData();
  }
}
