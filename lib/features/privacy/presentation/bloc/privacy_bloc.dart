// BLoC / Cubit state management for Privacy

abstract class PrivacyState {
  const PrivacyState();
}

class PrivacyInitial extends PrivacyState {
  const PrivacyInitial();
}

class PrivacyLoading extends PrivacyState {
  const PrivacyLoading();
}

class PrivacyLoaded extends PrivacyState {
  const PrivacyLoaded();
}

class PrivacyError extends PrivacyState {
  final String message;
  const PrivacyError(this.message);
}
