import 'package:equatable/equatable.dart';

import '../../../../core/models/user_model.dart';
import '../../domain/entities/send_otp_result.dart';

/// Auth state machine.
///
/// [AuthLoading] is emitted only while the persisted session is being
/// restored at startup; the app then settles on [AuthAuthenticated] or
/// [AuthGuest]. [AuthOtpSent] and [AuthError] are transient states used by the
/// sign-in screens.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Session restore (or sign-in submission) is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// No active session — the user is signed out.
class AuthGuest extends AuthState {
  const AuthGuest();
}

/// An OTP was successfully requested; [result] may contain a dev-only OTP.
class AuthOtpSent extends AuthState {
  final SendOtpResult result;

  const AuthOtpSent(this.result);

  @override
  List<Object?> get props => [result];
}

/// The user is signed in.
class AuthAuthenticated extends AuthState {
  final UserModel? user;

  /// Whether the backend reported an existing professional profile at
  /// sign-in/registration (`RegisterResponse.profile_created`). Always false
  /// after a session restore, since the flag is not persisted.
  final bool profileCreated;

  const AuthAuthenticated({this.user, this.profileCreated = false});

  @override
  List<Object?> get props => [user, profileCreated];
}

/// The last sign-in/registration attempt failed.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
