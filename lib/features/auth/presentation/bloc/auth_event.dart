import 'package:equatable/equatable.dart';

import '../../domain/usecases/password_login_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

/// Events the [AuthBloc] reacts to.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Restores the persisted session at startup (or after app resume).
class SessionRestoreRequested extends AuthEvent {
  const SessionRestoreRequested();
}

/// The token refresh interceptor detected an expired/revoked session.
class SessionExpired extends AuthEvent {
  const SessionExpired();
}

/// Creates a new account and signs the user in.
class RegisterSubmitted extends AuthEvent {
  final RegisterParams params;

  const RegisterSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}

/// Signs the user in with phone + password.
class PasswordLoginSubmitted extends AuthEvent {
  final PasswordLoginParams params;

  const PasswordLoginSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}

/// Requests a one-time password (e.g. before OTP verification).
class OtpRequested extends AuthEvent {
  final SendOtpParams params;

  const OtpRequested(this.params);

  @override
  List<Object?> get props => [params];
}

/// Exchanges an OTP for an authenticated session.
class OtpVerificationSubmitted extends AuthEvent {
  final VerifyOtpParams params;

  const OtpVerificationSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}

/// Signs the user out (best-effort server call, always clears the local
/// session).
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
