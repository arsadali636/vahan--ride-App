import '../entities/home_data.dart';

/// Repository for the home dashboard.
abstract class HomeRepository {
  /// Fetches the home dashboard data.
  Future<HomeData> getHomeData();
}
