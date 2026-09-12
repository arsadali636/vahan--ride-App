import '../entities/onboarding_entity.dart';

abstract class OnboardingRepository {
  Future<OnboardingEntity?> getOnboardingData();
}
