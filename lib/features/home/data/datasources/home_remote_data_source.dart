import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/home_response_model.dart';

/// Remote data source for the home dashboard endpoint.
abstract class HomeRemoteDataSource {
  /// Fetches the home dashboard data (stats, urgent jobs, suggested doctors).
  Future<HomeResponseModel> getHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<HomeResponseModel> getHomeData() async {
    final data = await apiClient.get(ApiEndpoints.feedHome);
    return HomeResponseModel.fromJson(
      (data as Map).cast<String, dynamic>(),
    );
  }
}
