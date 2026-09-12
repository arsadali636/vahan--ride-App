import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required this.remoteDataSource});

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<HomeData> getHomeData() async {
    try {
      final response = await remoteDataSource.getHomeData();
      return response.toEntity();
    } on ApiException catch (e) {
      throw FailureMapper.fromApiException(e);
    }
  }
}
