import '../entities/communities_entity.dart';

abstract class CommunitiesRepository {
  Future<CommunitiesEntity?> getCommunitiesData();
}
