import '../entities/onboarding_entity.dart';
import '../repositories/onboarding_repository.dart';

class GetOnboardingUseCase {
  final OnboardingRepository repository;

  GetOnboardingUseCase(this.repository);

  Future<OnboardingEntity?> call() async {
    return await repository.getOnboardingData();
  }
}
