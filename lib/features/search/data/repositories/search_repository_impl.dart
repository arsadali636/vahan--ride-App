import '../../domain/entities/search_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SearchEntity?> getSearchData() async {
    // TODO: Implement repository logic
    return null;
  }
}
