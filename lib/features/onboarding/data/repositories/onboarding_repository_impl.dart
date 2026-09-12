import '../../domain/entities/onboarding_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OnboardingEntity?> getOnboardingData() async {
    // TODO: Implement repository logic
    return null;
  }
}
