import '../../domain/entities/messaging_entity.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../datasources/messaging_remote_data_source.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingRemoteDataSource remoteDataSource;

  MessagingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MessagingEntity?> getMessagingData() async {
    // TODO: Implement repository logic
    return null;
  }
}
