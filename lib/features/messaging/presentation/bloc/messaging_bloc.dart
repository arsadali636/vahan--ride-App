// BLoC / Cubit state management for Messaging

abstract class MessagingState {
  const MessagingState();
}

class MessagingInitial extends MessagingState {
  const MessagingInitial();
}

class MessagingLoading extends MessagingState {
  const MessagingLoading();
}

class MessagingLoaded extends MessagingState {
  const MessagingLoaded();
}

class MessagingError extends MessagingState {
  final String message;
  const MessagingError(this.message);
}
