import 'package:flutter/foundation.dart';

/// Auth state used by the router to decide which routes are reachable.
enum AuthStatus {
  /// Session restore is still in progress; the router should not redirect yet.
  unknown,

  /// A valid session exists; every route is reachable.
  authenticated,

  /// No session; protected routes redirect to the login page.
  guest,
}

/// Synchronous, listenable view of the current auth status.
///
/// [AuthBloc] updates the value as sessions are restored/created/cleared and
/// GoRouter uses it via `refreshListenable` so redirects react instantly to
/// auth state changes without reaching into secure storage on every route.
class AuthGate extends ValueNotifier<AuthStatus> {
  AuthGate([super.value = AuthStatus.unknown]);
}
