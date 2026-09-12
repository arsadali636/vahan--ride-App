// BLoC / Cubit state management for Onboarding

abstract class OnboardingState {
  const OnboardingState();
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingLoaded extends OnboardingState {
  const OnboardingLoaded();
}

class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError(this.message);
}
