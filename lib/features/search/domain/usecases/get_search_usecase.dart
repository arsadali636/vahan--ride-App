import '../entities/search_entity.dart';
import '../repositories/search_repository.dart';

class GetSearchUseCase {
  final SearchRepository repository;

  GetSearchUseCase(this.repository);

  Future<SearchEntity?> call() async {
    return await repository.getSearchData();
  }
}
