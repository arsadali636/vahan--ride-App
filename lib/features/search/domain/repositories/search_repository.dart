import '../entities/search_entity.dart';

abstract class SearchRepository {
  Future<SearchEntity?> getSearchData();
}
