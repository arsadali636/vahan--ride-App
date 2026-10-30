import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:doc_connect_app/app/app_config.dart';
import 'package:doc_connect_app/app/environment_config.dart';
import 'package:doc_connect_app/core/api/api_client.dart';
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
import 'package:doc_connect_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:doc_connect_app/features/feed/domain/repositories/feed_repository.dart';
import 'package:doc_connect_app/features/feed/domain/usecases/get_feed_posts_usecase.dart';
import 'package:doc_connect_app/features/feed/domain/usecases/post_management_usecases.dart';
import 'package:doc_connect_app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:doc_connect_app/features/home/presentation/widgets/post_composer_sheet.dart';
import 'package:doc_connect_app/features/feed/presentation/bloc/post_composer_bloc.dart';
import 'package:doc_connect_app/features/home/domain/repositories/home_repository.dart';
import 'package:doc_connect_app/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:doc_connect_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:doc_connect_app/features/home/presentation/pages/home_page.dart';
import 'package:doc_connect_app/features/home/presentation/widgets/feed_tab.dart';
import 'package:doc_connect_app/features/home/presentation/widgets/jobs_tab.dart';
import 'package:doc_connect_app/features/home/presentation/widgets/main_navigation_bar.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_feed_repository.dart';
import '../helpers/fake_home_repository.dart';
import '../helpers/fake_session_service.dart';

void _setupTestInjection() {
  final getIt = GetIt.instance;
  getIt.reset();

  final fakeHomeRepo = FakeHomeRepository();
  final fakeFeedRepo = FakeFeedRepository();
  final dio = Dio()..options.baseUrl = 'http://localhost';
  final apiClient = ApiClient(dio);

  getIt
    ..registerLazySingleton<Dio>(() => dio)
    ..registerLazySingleton<ApiClient>(() => apiClient)
    ..registerLazySingleton<HomeRepository>(() => fakeHomeRepo)
    ..registerLazySingleton<GetHomeData>(() => GetHomeData(fakeHomeRepo))
    ..registerFactory<HomeBloc>(
      () => HomeBloc(getHomeData: getIt<GetHomeData>()),
    )
    ..registerLazySingleton<FeedRepository>(() => fakeFeedRepo)
    ..registerLazySingleton<GetFeedPosts>(() => GetFeedPosts(fakeFeedRepo))
    ..registerLazySingleton<CreatePost>(() => CreatePost(fakeFeedRepo))
    ..registerLazySingleton<LikePost>(() => LikePost(fakeFeedRepo))
    ..registerLazySingleton<EditPost>(() => EditPost(fakeFeedRepo))
    ..registerLazySingleton<DeletePost>(() => DeletePost(fakeFeedRepo))
    ..registerFactory<FeedBloc>(
      () => FeedBloc(
        getFeedPosts: getIt<GetFeedPosts>(),
        createPost: getIt<CreatePost>(),
        likePost: getIt<LikePost>(),
        editPost: getIt<EditPost>(),
        deletePost: getIt<DeletePost>(),
      ),
    )
    ..registerFactory<PostComposerBloc>(
      () => PostComposerBloc(createPost: getIt<CreatePost>()),
    );
}

AuthBloc _buildAuthBloc(
  AuthGate gate,
  FakeSessionService session, {
  FakeAuthRepository? repository,
}) {
  final repo = repository ?? FakeAuthRepository();
  return AuthBloc(
    sessionService: session,
    authGate: gate,
    restoreSession: RestoreSession(session),
    registerUser: RegisterUser(repo),
    passwordLogin: PasswordLogin(repo),
    sendOtp: SendOtpUseCase(repo),
    verifyOtp: VerifyOtp(repo),
    logout: Logout(repo, session),
  );
}

Widget _app(AuthBloc authBloc) {
  return BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: const MaterialApp(home: HomePage()),
  );
}

void main() {
  setUpAll(() {
    AppConfig.initialize(
      environmentConfig: const EnvironmentConfig.development(
        apiBaseUrl: 'http://3.111.58.158',
        apiBasePath: '/api/v1',
      ),
    );
  });

  group('HomePage shell', () {
    late FakeSessionService session;
    late AuthBloc authBloc;

    setUp(() {
      _setupTestInjection();
      session = FakeSessionService(
        session: SessionData(
          tokens: const AuthTokenPair(
            accessToken: 'access',
            refreshToken: 'refresh',
          ),
          userId: 'u-1',
          userRole: UserRole.doctor,
          profile: const UserModel(
            firstName: 'Ada',
            lastName: 'Lovelace',
            professionalHeadline: 'Consultant Cardiologist',
          ),
        ),
      );
      authBloc = _buildAuthBloc(AuthGate(), session);
    });

    testWidgets('shows the bottom navigation bar on top of the home feed', (
      tester,
    ) async {
      await tester.pumpWidget(_app(authBloc));
      await tester.pumpAndSettle();

      expect(find.byType(MainNavigationBar), findsOneWidget);
      expect(find.byType(FeedTab), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MainNavigationBar),
          matching: find.text('Home'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MainNavigationBar),
          matching: find.text('Network'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MainNavigationBar),
          matching: find.text('Jobs'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(MainNavigationBar),
          matching: find.text('Profile'),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('Create a post'), findsOneWidget);
    });

    testWidgets('switches between the four destinations', (tester) async {
      await tester.pumpWidget(_app(authBloc));
      await tester.pumpAndSettle();

      MainNavigationBar navBar() =>
          tester.widget<MainNavigationBar>(find.byType(MainNavigationBar));

      expect(navBar().selected, MainTab.home);

      await tester.tap(
        find.descendant(
          of: find.byType(MainNavigationBar),
          matching: find.text('Network'),
        ),
      );
      await tester.pumpAndSettle();
      expect(navBar().selected, MainTab.network);
      expect(find.text('My Network').hitTestable(), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(MainNavigationBar),
          matching: find.text('Jobs'),
        ),
      );
      await tester.pumpAndSettle();
      expect(navBar().selected, MainTab.jobs);
      expect(find.byType(JobsTab), findsOneWidget);
      expect(find.text('Opportunities').hitTestable(), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(MainNavigationBar),
          matching: find.text('Profile'),
        ),
      );
      await tester.pumpAndSettle();
      expect(navBar().selected, MainTab.account);
      expect(find.text('My Account').hitTestable(), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(MainNavigationBar),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();
      expect(navBar().selected, MainTab.home);
    });

    testWidgets('the center Post button opens the composer sheet', (
      tester,
    ) async {
      await tester.pumpWidget(_app(authBloc));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Create a post'));
      await tester.pumpAndSettle();

      expect(find.byType(PostComposerSheet), findsOneWidget);
      expect(find.text('Share your thoughts ...'), findsOneWidget);
      expect(find.text('Post'), findsWidgets);
    });

    testWidgets('calls getHomeData only once during initial HomePage loading', (
      tester,
    ) async {
      final fakeHomeRepo =
          GetIt.instance<HomeRepository>() as FakeHomeRepository;

      await tester.pumpWidget(_app(authBloc));
      await tester.pumpAndSettle();

      // Consolidates all tabs into 1 single call instead of 3 duplicate calls
      expect(fakeHomeRepo.getHomeDataCalls, 1);
    });

    testWidgets('signing out from the Profile tab logs the user out', (
      tester,
    ) async {
      final repository = FakeAuthRepository();
      authBloc = _buildAuthBloc(AuthGate(), session, repository: repository);
      await tester.pumpWidget(_app(authBloc));
      await tester.pumpAndSettle();
      expect(authBloc.state, isA<AuthAuthenticated>());

      await tester.tap(
        find.descendant(
          of: find.byType(MainNavigationBar),
          matching: find.text('Profile'),
        ),
      );
      await tester.pumpAndSettle();

      final signOutFinder = find.widgetWithText(ListTile, 'Sign out');
      await tester.ensureVisible(signOutFinder);
      await tester.pumpAndSettle();
      await tester.tap(signOutFinder);
      await tester.pumpAndSettle();

      expect(repository.logoutCalls, 1);
      expect(authBloc.state, isA<AuthGuest>());
    });
  });
}
