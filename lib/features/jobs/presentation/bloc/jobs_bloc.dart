// BLoC / Cubit state management for Jobs

abstract class JobsState {
  const JobsState();
}

class JobsInitial extends JobsState {
  const JobsInitial();
}

class JobsLoading extends JobsState {
  const JobsLoading();
}

class JobsLoaded extends JobsState {
  const JobsLoaded();
}

class JobsError extends JobsState {
  final String message;
  const JobsError(this.message);
}
