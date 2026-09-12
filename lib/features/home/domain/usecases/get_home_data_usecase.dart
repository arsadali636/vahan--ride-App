import '../entities/home_data.dart';
import '../repositories/home_repository.dart';

/// Fetches the home dashboard data.
class GetHomeData {
  GetHomeData(this._repository);

  final HomeRepository _repository;

  Future<HomeData> call() {
    return _repository.getHomeData();
  }
}
