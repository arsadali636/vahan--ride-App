// BLoC / Cubit state management for Availability

abstract class AvailabilityState {
  const AvailabilityState();
}

class AvailabilityInitial extends AvailabilityState {
  const AvailabilityInitial();
}

class AvailabilityLoading extends AvailabilityState {
  const AvailabilityLoading();
}

class AvailabilityLoaded extends AvailabilityState {
  const AvailabilityLoaded();
}

class AvailabilityError extends AvailabilityState {
  final String message;
  const AvailabilityError(this.message);
}
