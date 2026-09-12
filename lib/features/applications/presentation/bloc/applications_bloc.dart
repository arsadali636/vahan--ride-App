// BLoC / Cubit state management for Applications

abstract class ApplicationsState {
  const ApplicationsState();
}

class ApplicationsInitial extends ApplicationsState {
  const ApplicationsInitial();
}

class ApplicationsLoading extends ApplicationsState {
  const ApplicationsLoading();
}

class ApplicationsLoaded extends ApplicationsState {
  const ApplicationsLoaded();
}

class ApplicationsError extends ApplicationsState {
  final String message;
  const ApplicationsError(this.message);
}
