import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/auth/auth_gate.dart';
import 'package:doc_connect_app/core/enums/user_role.dart';
import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/core/models/user_model.dart';
import 'package:doc_connect_app/core/storage/session_service.dart';
import 'package:doc_connect_app/features/auth/domain/entities/auth_session.dart';
import 'package:doc_connect_app/features/auth/domain/entities/otp_purpose.dart';
import 'package:doc_connect_app/features/auth/domain/entities/send_otp_result.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/password_login_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:doc_connect_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:doc_connect_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:doc_connect_app/features/auth/presentation/bloc/auth_state.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_session_service.dart';

Future<T> _awaitState<T>(AuthBloc bloc, void Function() trigger) async {
  final done = bloc.stream.firstWhere((state) => state is T);
  trigger();
  return done.then((state) => state as T).timeout(const Duration(seconds: 5));
}

Future<void> _settleRestore(AuthBloc bloc) async {
  await bloc.stream
      .firstWhere((state) => state is AuthGuest || state is AuthAuthenticated)
      .timeout(const Duration(seconds: 5));
}

void main() {
  group('AuthBloc', () {
    late FakeSessionService session;
    late FakeAuthRepository repository;
    late AuthGate gate;
    late AuthBloc bloc;

    AuthBloc build() {
      return AuthBloc(
        sessionService: session,
        authGate: gate,
        restoreSession: RestoreSession(session),
        registerUser: RegisterUser(repository),
        passwordLogin: PasswordLogin(repository),
        sendOtp: SendOtpUseCase(repository),
        verifyOtp: VerifyOtp(repository),
        logout: Logout(repository, session),
      );
    }

    setUp(() {
      session = FakeSessionService();
      repository = FakeAuthRepository();
      gate = AuthGate();
      bloc = build();
    });

    tearDown(() => bloc.close());

    test('restores a guest session on startup', () async {
      await _settleRestore(bloc);

      expect(bloc.state, isA<AuthGuest>());
      expect(gate.value, AuthStatus.guest);
    });

    test('restores an authenticated session on startup', () async {
      session = FakeSessionService(
        session: const SessionData(
          tokens: AuthTokenPair(accessToken: 'access', refreshToken: 'refresh'),
          userId: 'u-1',
          userRole: UserRole.doctor,
          profile: UserModel(firstName: 'Ada', lastName: 'Lovelace'),
        ),
      );
      bloc = build();

      await _settleRestore(bloc);

      expect(bloc.state, isA<AuthAuthenticated>());
      expect((bloc.state as AuthAuthenticated).user?.firstName, 'Ada');
      expect(gate.value, AuthStatus.authenticated);
    });

    test('register persists the session and authenticates', () async {
      repository.registerResult = const AuthSession(
        tokens: AuthTokenPair(accessToken: 'at', refreshToken: 'rt'),
        userId: 'u-1',
        userRole: UserRole.hospital,
        profileCreated: true,
      );

      await _awaitState<AuthAuthenticated>(bloc, () {
        bloc.add(
          const RegisterSubmitted(
            RegisterParams(
              firstName: 'Ada',
              lastName: 'Lovelace',
              phone: '9876543210',
              password: 'secret123',
              userType: UserRole.hospital,
            ),
          ),
        );
      });

      expect(bloc.state, isA<AuthAuthenticated>());
      expect(gate.value, AuthStatus.authenticated);
      expect(session.session?.userId, 'u-1');
      expect(session.session?.userRole, UserRole.hospital);
      expect(session.session?.tokens.accessToken, 'at');
      expect((bloc.state as AuthAuthenticated).profileCreated, isTrue);
    });

    test('register failure emits AuthError with the failure message', () async {
      repository.errorToThrow = const ValidationFailure('phone: Invalid value');

      await _awaitState<AuthError>(bloc, () {
        bloc.add(
          const RegisterSubmitted(
            RegisterParams(
              firstName: 'Ada',
              lastName: 'Lovelace',
              phone: '999',
              password: 'x',
            ),
          ),
        );
      });

      expect((bloc.state as AuthError).message, 'phone: Invalid value');
      expect(gate.value, AuthStatus.guest);
    });

    test('password login authenticates and saves the tokens', () async {
      repository.loginResult = const AuthSession(
        tokens: AuthTokenPair(accessToken: 'at', refreshToken: 'rt'),
      );

      await _awaitState<AuthAuthenticated>(bloc, () {
        bloc.add(
          const PasswordLoginSubmitted(
            PasswordLoginParams(phone: '9876543210', password: 'pass'),
          ),
        );
      });

      expect(gate.value, AuthStatus.authenticated);
      expect(session.session?.tokens.accessToken, 'at');
      expect(repository.lastPhone, '9876543210');
      expect(repository.lastPassword, 'pass');
    });

    test('password login failure emits AuthError', () async {
      repository.errorToThrow = const UnauthorizedFailure('Invalid password');

      await _awaitState<AuthError>(bloc, () {
        bloc.add(
          const PasswordLoginSubmitted(
            PasswordLoginParams(phone: '9876543210', password: 'wrong'),
          ),
        );
      });

      expect((bloc.state as AuthError).message, 'Invalid password');
      expect(gate.value, AuthStatus.guest);
    });

    test('OTP request emits AuthOtpSent carrying the dev OTP', () async {
      repository.sendOtpResult = const SendOtpResult(
        success: true,
        message: 'OTP generated',
        expiresIn: 300,
        otp: '335345',
      );

      await _awaitState<AuthOtpSent>(bloc, () {
        bloc.add(
          const OtpRequested(
            SendOtpParams(phone: '9876543210', purpose: OtpPurpose.login),
          ),
        );
      });

      final state = bloc.state as AuthOtpSent;
      expect(state.result.otp, '335345');
      expect(repository.lastPhone, '9876543210');
    });

    test('OTP verification authenticates', () async {
      repository.loginResult = const AuthSession(
        tokens: AuthTokenPair(accessToken: 'at', refreshToken: 'rt'),
      );

      await _awaitState<AuthAuthenticated>(bloc, () {
        bloc.add(
          const OtpVerificationSubmitted(
            VerifyOtpParams(phone: '9876543210', otp: '123456'),
          ),
        );
      });

      expect(gate.value, AuthStatus.authenticated);
      expect(session.session?.tokens.refreshToken, 'rt');
    });

    test('logout clears the session and returns to guest', () async {
      session = FakeSessionService(
        session: const SessionData(
          tokens: AuthTokenPair(accessToken: 'a', refreshToken: 'r'),
        ),
      );
      bloc = build();
      await _settleRestore(bloc);
      expect(bloc.state, isA<AuthAuthenticated>());

      await _awaitState<AuthGuest>(bloc, () {
        bloc.add(const LogoutRequested());
      });

      expect(bloc.state, isA<AuthGuest>());
      expect(gate.value, AuthStatus.guest);
      expect(session.session, isNull);
      expect(repository.logoutCalls, 1);
    });

    test(
      'logout clears the session even when the server call throws',
      () async {
        session = FakeSessionService(
          session: const SessionData(
            tokens: AuthTokenPair(accessToken: 'a', refreshToken: 'r'),
          ),
        );
        repository.errorToThrow = const NetworkFailure('offline');
        bloc = build();
        await _settleRestore(bloc);

        await _awaitState<AuthGuest>(bloc, () {
          bloc.add(const LogoutRequested());
        });

        expect(session.session, isNull);
        expect(gate.value, AuthStatus.guest);
      },
    );

    test(
      'handleSessionExpired clears the session without calling the server',
      () async {
        session = FakeSessionService(
          session: const SessionData(
            tokens: AuthTokenPair(accessToken: 'a', refreshToken: 'r'),
          ),
        );
        bloc = build();
        await _settleRestore(bloc);

        await _awaitState<AuthGuest>(bloc, () {
          bloc.handleSessionExpired();
        });

        expect(bloc.state, isA<AuthGuest>());
        expect(gate.value, AuthStatus.guest);
        expect(session.session, isNull);
        expect(repository.logoutCalls, 0);
      },
    );
  });
}
