import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../core/api/api_client.dart';
import '../core/auth/auth_gate.dart';
import '../core/network/dio_factory.dart';
import '../core/network/network_info.dart';
import '../core/network/network_info_impl.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/storage/session_service.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/password_login_usecase.dart';
import '../features/auth/domain/usecases/refresh_token_usecase.dart';
import '../features/auth/domain/usecases/register_user_usecase.dart';
import '../features/auth/domain/usecases/restore_session_usecase.dart';
import '../features/auth/domain/usecases/send_otp_usecase.dart';
import '../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/feed/data/datasources/feed_remote_data_source.dart';
import '../features/feed/data/repositories/feed_repository_impl.dart';
import '../features/feed/domain/repositories/feed_repository.dart';
import '../features/feed/domain/usecases/get_feed_posts_usecase.dart';
import '../features/feed/domain/usecases/post_management_usecases.dart';
import '../features/feed/presentation/bloc/comment_bloc.dart';
import '../features/feed/presentation/bloc/feed_bloc.dart';
import '../features/feed/presentation/bloc/post_composer_bloc.dart';
import '../features/home/data/datasources/home_remote_data_source.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/domain/usecases/get_home_data_usecase.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/doctor_network/data/datasources/doctor_network_remote_data_source.dart';
import '../features/doctor_network/data/repositories/doctor_network_repository_impl.dart';
import '../features/doctor_network/domain/repositories/doctor_network_repository.dart';
import '../features/doctor_network/domain/usecases/get_public_doctor_profile.dart';
import '../features/doctor_network/domain/usecases/search_doctors.dart';
import '../features/doctor_network/presentation/bloc/doctor_network_bloc.dart';
import '../features/professional_identity/data/datasources/doctor_profile_remote_data_source.dart';
import '../features/professional_identity/data/repositories/doctor_profile_repository_impl.dart';
import '../features/professional_identity/domain/repositories/doctor_profile_repository.dart';
import '../features/professional_identity/domain/usecases/add_experience_usecase.dart';
import '../features/professional_identity/domain/usecases/add_qualification_usecase.dart';
import '../features/professional_identity/domain/usecases/add_registration_usecase.dart';
import '../features/professional_identity/domain/usecases/create_doctor_profile_usecase.dart';
import '../features/professional_identity/domain/usecases/delete_experience_usecase.dart';
import '../features/professional_identity/domain/usecases/delete_qualification_usecase.dart';
import '../features/professional_identity/domain/usecases/get_doctor_profile_usecase.dart';
import '../features/professional_identity/domain/usecases/list_experiences_usecase.dart';
import '../features/professional_identity/domain/usecases/list_qualifications_usecase.dart';
import '../features/professional_identity/domain/usecases/list_registrations_usecase.dart';
import '../features/professional_identity/domain/usecases/update_doctor_profile_usecase.dart';
import '../features/professional_identity/domain/usecases/upload_profile_photo_usecase.dart';
import '../features/professional_identity/presentation/bloc/doctor_profile_bloc.dart';
import 'app_config.dart';
import 'app_router.dart';

/// Service locator for the whole app.
///
/// Core infrastructure is registered here during bootstrap; each feature
/// registers its own models/repositories/usecases/blocs via
/// `DependencyInjection.instance` (e.g. `FeatureInjector().register()`).
class DependencyInjection {
  DependencyInjection._();

  static final GetIt _getIt = GetIt.instance;

  static GetIt get instance => _getIt;

  static Future<void> init() async {
    _registerCore();
    _registerFeatures();
  }

  static void _registerCore() {
    final config = AppConfig.instance.environmentConfig;

    _getIt
      ..registerLazySingleton<SecureStorageService>(SecureStorageServiceImpl.new)
      ..registerLazySingleton<SessionService>(
        () => SessionServiceImpl(_getIt<SecureStorageService>()),
      )
      ..registerLazySingleton<AuthGate>(AuthGate.new)
      ..registerLazySingleton<NetworkInfo>(NetworkInfoImpl.new)
      ..registerLazySingleton<Dio>(() => _createDio(config.apiBaseUrl))
      ..registerLazySingleton<ApiClient>(() => ApiClient(_getIt<Dio>()))
      ..registerLazySingleton<GoRouter>(
        () => AppRouter(authGate: _getIt<AuthGate>()).router,
      );
  }

  /// Feature registrations. Each feature adds its own injector here as it is
  /// implemented.
  static void _registerFeatures() {
    _getIt
      ..registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(apiClient: _getIt<ApiClient>()),
      )
      ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          remoteDataSource: _getIt<AuthRemoteDataSource>(),
        ),
      )
      ..registerLazySingleton<SendOtpUseCase>(
        () => SendOtpUseCase(_getIt<AuthRepository>()),
      )
      ..registerLazySingleton<RegisterUser>(
        () => RegisterUser(_getIt<AuthRepository>()),
      )
      ..registerLazySingleton<PasswordLogin>(
        () => PasswordLogin(_getIt<AuthRepository>()),
      )
      ..registerLazySingleton<VerifyOtp>(
        () => VerifyOtp(_getIt<AuthRepository>()),
      )
      ..registerLazySingleton<Logout>(
        () => Logout(
          _getIt<AuthRepository>(),
          _getIt<SessionService>(),
        ),
      )
      ..registerLazySingleton<RestoreSession>(
        () => RestoreSession(_getIt<SessionService>()),
      )
      ..registerLazySingleton<RefreshToken>(
        () => RefreshToken(_getIt<AuthRepository>()),
      )
      ..registerLazySingleton<AuthBloc>(
        () => AuthBloc(
          sessionService: _getIt<SessionService>(),
          authGate: _getIt<AuthGate>(),
          restoreSession: _getIt<RestoreSession>(),
          registerUser: _getIt<RegisterUser>(),
          passwordLogin: _getIt<PasswordLogin>(),
          sendOtp: _getIt<SendOtpUseCase>(),
          verifyOtp: _getIt<VerifyOtp>(),
          logout: _getIt<Logout>(),
        ),
      )
      ..registerLazySingleton<DoctorProfileRemoteDataSource>(
        () => DoctorProfileRemoteDataSourceImpl(
          apiClient: _getIt<ApiClient>(),
        ),
      )
      ..registerLazySingleton<DoctorProfileRepository>(
        () => DoctorProfileRepositoryImpl(
          remoteDataSource: _getIt<DoctorProfileRemoteDataSource>(),
        ),
      )
      ..registerLazySingleton<CreateDoctorProfile>(
        () => CreateDoctorProfile(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<GetDoctorProfile>(
        () => GetDoctorProfile(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<UpdateDoctorProfile>(
        () => UpdateDoctorProfile(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<UploadProfilePhoto>(
        () => UploadProfilePhoto(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<ListQualifications>(
        () => ListQualifications(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<AddQualification>(
        () => AddQualification(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<DeleteQualification>(
        () => DeleteQualification(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<ListRegistrations>(
        () => ListRegistrations(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<AddRegistration>(
        () => AddRegistration(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<ListExperiences>(
        () => ListExperiences(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<AddExperience>(
        () => AddExperience(_getIt<DoctorProfileRepository>()),
      )
      ..registerLazySingleton<DeleteExperience>(
        () => DeleteExperience(_getIt<DoctorProfileRepository>()),
      )
      ..registerFactory<DoctorProfileBloc>(
        () => DoctorProfileBloc(
          sessionService: _getIt<SessionService>(),
          getDoctorProfile: _getIt<GetDoctorProfile>(),
          createDoctorProfile: _getIt<CreateDoctorProfile>(),
          updateDoctorProfile: _getIt<UpdateDoctorProfile>(),
          uploadProfilePhoto: _getIt<UploadProfilePhoto>(),
          listQualifications: _getIt<ListQualifications>(),
          addQualification: _getIt<AddQualification>(),
          deleteQualification: _getIt<DeleteQualification>(),
          listRegistrations: _getIt<ListRegistrations>(),
          addRegistration: _getIt<AddRegistration>(),
          listExperiences: _getIt<ListExperiences>(),
          addExperience: _getIt<AddExperience>(),
          deleteExperience: _getIt<DeleteExperience>(),
        ),
      )
      ..registerLazySingleton<DoctorNetworkRemoteDataSource>(
        () => DoctorNetworkRemoteDataSourceImpl(
          apiClient: _getIt<ApiClient>(),
        ),
      )
      ..registerLazySingleton<DoctorNetworkRepository>(
        () => DoctorNetworkRepositoryImpl(
          remoteDataSource: _getIt<DoctorNetworkRemoteDataSource>(),
        ),
      )
      ..registerLazySingleton<SearchDoctors>(
        () => SearchDoctors(_getIt<DoctorNetworkRepository>()),
      )
      ..registerLazySingleton<GetPublicDoctorProfile>(
        () => GetPublicDoctorProfile(_getIt<DoctorNetworkRepository>()),
      )
      ..registerFactory<DoctorNetworkBloc>(
        () => DoctorNetworkBloc(
          searchDoctors: _getIt<SearchDoctors>(),
          getDoctorProfile: _getIt<GetPublicDoctorProfile>(),
        ),
      )
      // ── Feed ─────────────────────────────────────────────────────────────
      ..registerLazySingleton<FeedRemoteDataSource>(
        () => FeedRemoteDataSourceImpl(apiClient: _getIt<ApiClient>()),
      )
      ..registerLazySingleton<FeedRepository>(
        () => FeedRepositoryImpl(
          remoteDataSource: _getIt<FeedRemoteDataSource>(),
        ),
      )
      ..registerLazySingleton<GetFeedPosts>(
        () => GetFeedPosts(_getIt<FeedRepository>()),
      )
      ..registerLazySingleton<CreatePost>(
        () => CreatePost(_getIt<FeedRepository>()),
      )
      ..registerLazySingleton<LikePost>(
        () => LikePost(_getIt<FeedRepository>()),
      )
      // Post management use cases
      ..registerLazySingleton<EditPost>(
        () => EditPost(_getIt<FeedRepository>()),
      )
      ..registerLazySingleton<DeletePost>(
        () => DeletePost(_getIt<FeedRepository>()),
      )
      ..registerLazySingleton<GetComments>(
        () => GetComments(_getIt<FeedRepository>()),
      )
      ..registerLazySingleton<PostComment>(
        () => PostComment(_getIt<FeedRepository>()),
      )
      ..registerLazySingleton<ReplyComment>(
        () => ReplyComment(_getIt<FeedRepository>()),
      )
      ..registerLazySingleton<EditComment>(
        () => EditComment(_getIt<FeedRepository>()),
      )
      ..registerLazySingleton<DeleteComment>(
        () => DeleteComment(_getIt<FeedRepository>()),
      )
      // Comment BLoC
      ..registerFactory<CommentBloc>(
        () => CommentBloc(
          getComments: _getIt<GetComments>(),
          postComment: _getIt<PostComment>(),
          replyComment: _getIt<ReplyComment>(),
          editComment: _getIt<EditComment>(),
          deleteComment: _getIt<DeleteComment>(),
        ),
      )
      ..registerFactory<FeedBloc>(
        () => FeedBloc(
          getFeedPosts: _getIt<GetFeedPosts>(),
          createPost: _getIt<CreatePost>(),
          likePost: _getIt<LikePost>(),
          editPost: _getIt<EditPost>(),
          deletePost: _getIt<DeletePost>(),
        ),
      )
      ..registerFactory<PostComposerBloc>(
        () => PostComposerBloc(createPost: _getIt<CreatePost>()),
      )
      // ── Home dashboard ───────────────────────────────────────────────────
      ..registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(apiClient: _getIt<ApiClient>()),
      )
      ..registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(
          remoteDataSource: _getIt<HomeRemoteDataSource>(),
        ),
      )
      ..registerLazySingleton<GetHomeData>(
        () => GetHomeData(_getIt<HomeRepository>()),
      )
      ..registerFactory<HomeBloc>(
        () => HomeBloc(getHomeData: _getIt<GetHomeData>()),
      );
  }

  static Dio _createDio(String apiBaseUrl) {
    return DioFactory.create(
      baseUrl: apiBaseUrl,
      sessionService: _getIt<SessionService>(),
      refreshHandler: (refreshToken) =>
          _getIt<RefreshToken>().call(refreshToken),
      networkInfo: _getIt<NetworkInfo>(),
      onSessionExpired: () async {
        _getIt<AuthBloc>().handleSessionExpired();
      },
    );
  }

  /// Convenience accessor for registered dependencies.
  static T get<T extends Object>() => _getIt<T>();
}
