import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/auth/auth_gate.dart';
import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/features/auth/domain/entities/send_otp_result.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/password_login_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:doc_connect_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:doc_connect_app/features/auth/presentation/pages/auth_page.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_session_service.dart';

void main() {
  late FakeSessionService session;
  late FakeAuthRepository repository;
  late AuthGate gate;
  late AuthBloc bloc;

  AuthBloc buildBloc() {
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

  Future<void> pumpAuthPage(WidgetTester tester) async {
    // Build the bloc inside the widget test so its event processing runs in
    // the test's fake-async zone and completes under pump().
    bloc = buildBloc();
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: bloc,
          child: const AuthPage(),
        ),
      ),
    );
    // Let the initial session restore settle.
    await tester.pump();
  }

  /// Advances through the bloc handler's async chain and the resulting frame.
  Future<void> pumpBloc(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  setUp(() {
    session = FakeSessionService();
    repository = FakeAuthRepository();
    gate = AuthGate();
  });

  tearDown(() => bloc.close());

  testWidgets('renders the password login form by default', (tester) async {
    await pumpAuthPage(tester);

    expect(find.text('Sign in to continue.'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Phone number'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Continue with OTP'), findsOneWidget);
  });

  testWidgets('validates the phone number before submitting', (tester) async {
    await pumpAuthPage(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'pass',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter a valid 10-digit phone number'), findsOneWidget);
    expect(repository.lastPhone, isNull);
  });

  testWidgets('shows a SnackBar when sign-in fails', (tester) async {
    repository.errorToThrow = const UnauthorizedFailure('Invalid password');
    await pumpAuthPage(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '9876543210',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'wrong',
    );
    await tester.tap(find.text('Sign in'));
    await pumpBloc(tester);

    expect(repository.lastPhone, '9876543210');
    expect(find.text('Invalid password'), findsOneWidget);
  });

  testWidgets('switches to the OTP step and reveals the dev OTP', (
    tester,
  ) async {
    repository.sendOtpResult = const SendOtpResult(
      success: true,
      message: 'OTP generated',
      expiresIn: 300,
      otp: '335345',
    );
    await pumpAuthPage(tester);

    await tester.tap(find.text('Continue with OTP'));
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone number'),
      '9876543210',
    );
    await tester.tap(find.text('Send OTP'));
    await pumpBloc(tester);

    expect(find.text('One-time password'), findsOneWidget);
    expect(find.textContaining('335345'), findsOneWidget);
    expect(find.text('Verify & sign in'), findsOneWidget);
  });

  testWidgets('register mode collects account details', (tester) async {
    await pumpAuthPage(tester);

    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(find.text('Create your account to get started.'), findsOneWidget);
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Last name'), findsOneWidget);
    expect(find.text('Account type'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
