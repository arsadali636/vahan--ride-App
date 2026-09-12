// BLoC / Cubit state management for Communities

abstract class CommunitiesState {
  const CommunitiesState();
}

class CommunitiesInitial extends CommunitiesState {
  const CommunitiesInitial();
}

class CommunitiesLoading extends CommunitiesState {
  const CommunitiesLoading();
}

class CommunitiesLoaded extends CommunitiesState {
  const CommunitiesLoaded();
}

class CommunitiesError extends CommunitiesState {
  final String message;
  const CommunitiesError(this.message);
}
