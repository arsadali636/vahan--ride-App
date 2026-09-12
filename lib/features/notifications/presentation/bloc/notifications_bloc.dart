// BLoC / Cubit state management for Notifications

abstract class NotificationsState {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded();
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
}
