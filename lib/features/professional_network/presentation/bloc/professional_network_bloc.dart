// BLoC / Cubit state management for ProfessionalNetwork

abstract class ProfessionalNetworkState {
  const ProfessionalNetworkState();
}

class ProfessionalNetworkInitial extends ProfessionalNetworkState {
  const ProfessionalNetworkInitial();
}

class ProfessionalNetworkLoading extends ProfessionalNetworkState {
  const ProfessionalNetworkLoading();
}

class ProfessionalNetworkLoaded extends ProfessionalNetworkState {
  const ProfessionalNetworkLoaded();
}

class ProfessionalNetworkError extends ProfessionalNetworkState {
  final String message;
  const ProfessionalNetworkError(this.message);
}
