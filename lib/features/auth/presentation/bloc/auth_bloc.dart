// ignore_for_file: prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_gate.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/session_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/password_login_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Orchestrates the authentication lifecycle: session restore, register,
/// password login, OTP login and logout.
///
/// The UI talks to this bloc only — it never calls repositories, usecases or
/// [SessionService] directly. On every successful sign-in the session is
/// persisted through [SessionService] and [AuthGate] is flipped to
/// authenticated so the router unlocks protected routes.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SessionService sessionService,
    required AuthGate authGate,
    required RestoreSession restoreSession,
    required RegisterUser registerUser,
    required PasswordLogin passwordLogin,
    required SendOtpUseCase sendOtp,
    required VerifyOtp verifyOtp,
    required Logout logout,
  }) : _sessionService = sessionService,
       _authGate = authGate,
       _restoreSession = restoreSession,
       _registerUser = registerUser,
       _passwordLogin = passwordLogin,
       _sendOtp = sendOtp,
       _verifyOtp = verifyOtp,
       _logout = logout,
       super(const AuthLoading()) {
    on<SessionRestoreRequested>(_onRestoreRequested);
    on<SessionExpired>(_onSessionExpired);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<PasswordLoginSubmitted>(_onPasswordLoginSubmitted);
    on<OtpRequested>(_onOtpRequested);
    on<OtpVerificationSubmitted>(_onOtpVerificationSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    add(const SessionRestoreRequested());
  }

  final SessionService _sessionService;
  final AuthGate _authGate;
  final RestoreSession _restoreSession;
  final RegisterUser _registerUser;
  final PasswordLogin _passwordLogin;
  final SendOtpUseCase _sendOtp;
  final VerifyOtp _verifyOtp;
  final Logout _logout;

  /// Restores the persisted session (if any) on startup.
  Future<void> _onRestoreRequested(
    SessionRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _authGate.value = AuthStatus.unknown;
    try {
      final session = await _restoreSession();
      if (session != null) {
        emit(
          AuthAuthenticated(
            user: session.profile,
            profileCreated: session.profileCreated,
          ),
        );
        _authGate.value = AuthStatus.authenticated;
      } else {
        emit(const AuthGuest());
        _authGate.value = AuthStatus.guest;
      }
    } catch (_) {
      emit(const AuthGuest());
      _authGate.value = AuthStatus.guest;
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthGuest());
    try {
      final session = await _registerUser(event.params);
      await _persistAndAuthenticate(session, emit);
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onPasswordLoginSubmitted(
    PasswordLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthGuest());
    try {
      final session = await _passwordLogin(event.params);
      await _persistAndAuthenticate(session, emit);
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onOtpRequested(
    OtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthGuest());
    try {
      final result = await _sendOtp(event.params);
      emit(AuthOtpSent(result));
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onOtpVerificationSubmitted(
    OtpVerificationSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthGuest());
    try {
      final session = await _verifyOtp(event.params);
      await _persistAndAuthenticate(session, emit);
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const AuthGuest());
    _authGate.value = AuthStatus.guest;
  }

  /// Persists the tokens (and, when present, the user id/role) and marks the
  /// session as authenticated so the router redirects to the home screen.
  ///
  /// [AuthSession.profileCreated] is surfaced on [AuthAuthenticated] so the UI
  /// can branch to profile-completion when the backend reports that no
  /// professional profile exists yet.
  Future<void> _persistAndAuthenticate(
    AuthSession session,
    Emitter<AuthState> emit,
  ) async {
    await _sessionService.saveSession(
      tokens: session.tokens,
      userId: session.userId,
      userRole: session.userRole,
      profileCreated: session.profileCreated,
    );
    emit(AuthAuthenticated(user: null, profileCreated: session.profileCreated));
    _authGate.value = AuthStatus.authenticated;
  }

  /// Clears the local session without calling the server.
  ///
  /// Used when the token refresh interceptor detects an expired session
  /// (which may coincide with the network being unavailable).
  void handleSessionExpired() => add(const SessionExpired());

  Future<void> _onSessionExpired(
    SessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _sessionService.clearSession();
    emit(const AuthGuest());
    _authGate.value = AuthStatus.guest;
  }

  /// User-initiated sign-out.
  void signOut() => add(const LogoutRequested());
}
