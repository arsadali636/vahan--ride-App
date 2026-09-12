import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/app/app.dart';
import 'package:doc_connect_app/app/app_config.dart';
import 'package:doc_connect_app/app/app_router.dart';
import 'package:doc_connect_app/app/environment_config.dart';
import 'package:doc_connect_app/core/auth/auth_gate.dart';
import 'package:doc_connect_app/core/enums/user_role.dart';
import 'package:doc_connect_app/core/models/user_model.dart';
import 'package:doc_connect_app/core/storage/session_service.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/password_login_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:doc_connect_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:doc_connect_app/features/auth/presentation/pages/auth_page.dart';
import 'package:doc_connect_app/features/home/presentation/pages/home_page.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_session_service.dart';

AuthBloc _buildAuthBloc(AuthGate gate, FakeSessionService session) {
  final repository = FakeAuthRepository();
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

void main() {
  test('AppConfig can be initialized with a test environment', () {
    AppConfig.initialize(
      environmentConfig: const EnvironmentConfig.development(),
    );

    expect(AppConfig.instance.appTitle, 'MedNexus');
    expect(
      AppConfig.instance.environmentConfig.environment,
      AppEnvironment.development,
    );
  });

  testWidgets('Logged-out boot redirects to the login page', (tester) async {
    AppConfig.initialize(
      environmentConfig: const EnvironmentConfig.development(),
    );
    final gate = AuthGate();
    final authBloc = _buildAuthBloc(gate, FakeSessionService());
    final router = AppRouter(authGate: gate).router;

    await tester.pumpWidget(MedNexusApp(router: router, authBloc: authBloc));
    await tester.pumpAndSettle();

    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets('Authenticated boot lands on the home page', (tester) async {
    AppConfig.initialize(
      environmentConfig: const EnvironmentConfig.development(),
    );
    final session = SessionData(
      tokens: const AuthTokenPair(
        accessToken: 'access',
        refreshToken: 'refresh',
      ),
      userId: 'u-1',
      userRole: UserRole.doctor,
      profile: const UserModel(firstName: 'Ada', lastName: 'Lovelace'),
    );
    final gate = AuthGate();
    final authBloc = _buildAuthBloc(gate, FakeSessionService(session: session));
    final router = AppRouter(authGate: gate).router;

    await tester.pumpWidget(MedNexusApp(router: router, authBloc: authBloc));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(AuthPage), findsNothing);
  });
}
