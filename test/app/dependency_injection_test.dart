import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/app/app_config.dart';
import 'package:doc_connect_app/app/dependency_injection.dart';
import 'package:doc_connect_app/app/environment_config.dart';
import 'package:doc_connect_app/core/api/api_client.dart';
import 'package:doc_connect_app/core/auth/auth_gate.dart';
import 'package:doc_connect_app/core/storage/session_service.dart';
import 'package:doc_connect_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:doc_connect_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/password_login_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:doc_connect_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:doc_connect_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:doc_connect_app/features/professional_identity/data/datasources/doctor_profile_remote_data_source.dart';
import 'package:doc_connect_app/features/professional_identity/domain/repositories/doctor_profile_repository.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/create_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/get_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/update_doctor_profile_usecase.dart';

void main() {
  setUp(() {
    AppConfig.initialize(
      environmentConfig: const EnvironmentConfig.development(
        apiBaseUrl: 'http://test',
      ),
    );
  });

  tearDown(() => DependencyInjection.instance.reset());

  test('resolves the whole auth feature through the DI graph', () async {
    await DependencyInjection.init();

    // Core infra.
    expect(DependencyInjection.instance.isRegistered<SessionService>(), isTrue);
    expect(DependencyInjection.instance.isRegistered<ApiClient>(), isTrue);
    expect(DependencyInjection.instance.isRegistered<AuthGate>(), isTrue);

    // Feature chain: data source → repository → usecases → bloc.
    expect(
      DependencyInjection.instance.isRegistered<AuthRemoteDataSource>(),
      isTrue,
    );
    expect(DependencyInjection.instance.isRegistered<AuthRepository>(), isTrue);
    expect(DependencyInjection.get<SendOtpUseCase>(), isA<SendOtpUseCase>());
    expect(DependencyInjection.get<RegisterUser>(), isA<RegisterUser>());
    expect(DependencyInjection.get<PasswordLogin>(), isA<PasswordLogin>());
    expect(DependencyInjection.get<VerifyOtp>(), isA<VerifyOtp>());
    expect(DependencyInjection.get<Logout>(), isA<Logout>());
    expect(DependencyInjection.get<RestoreSession>(), isA<RestoreSession>());
    expect(DependencyInjection.get<RefreshToken>(), isA<RefreshToken>());

    final authBloc = DependencyInjection.get<AuthBloc>();
    expect(authBloc, isA<AuthBloc>());
    await authBloc.close();

    // Professional identity (doctor profile) chain.
    expect(
      DependencyInjection.instance
          .isRegistered<DoctorProfileRemoteDataSource>(),
      isTrue,
    );
    expect(
      DependencyInjection.instance.isRegistered<DoctorProfileRepository>(),
      isTrue,
    );
    expect(
      DependencyInjection.get<CreateDoctorProfile>(),
      isA<CreateDoctorProfile>(),
    );
    expect(
      DependencyInjection.get<GetDoctorProfile>(),
      isA<GetDoctorProfile>(),
    );
    expect(
      DependencyInjection.get<UpdateDoctorProfile>(),
      isA<UpdateDoctorProfile>(),
    );
  });
}
