import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

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
import 'package:doc_connect_app/features/feed/domain/usecases/get_feed_posts_usecase.dart';
import 'package:doc_connect_app/features/feed/domain/usecases/post_management_usecases.dart';
import 'package:doc_connect_app/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:doc_connect_app/features/feed/presentation/bloc/post_composer_bloc.dart';
import 'package:doc_connect_app/features/home/presentation/widgets/post_composer_sheet.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_feed_repository.dart';
import '../helpers/fake_session_service.dart';

void main() {
  group('PostComposerSheet (LinkedIn-Style)', () {
    late FakeSessionService session;
    late FakeFeedRepository feedRepository;
    late AuthBloc authBloc;
    late FeedBloc feedBloc;

    setUp(() async {
      final getIt = GetIt.instance;
      await getIt.reset();

      feedRepository = FakeFeedRepository();
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

      final authRepo = FakeAuthRepository();
      authBloc = AuthBloc(
        sessionService: session,
        authGate: AuthGate(),
        restoreSession: RestoreSession(session),
        registerUser: RegisterUser(authRepo),
        passwordLogin: PasswordLogin(authRepo),
        sendOtp: SendOtpUseCase(authRepo),
        verifyOtp: VerifyOtp(authRepo),
        logout: Logout(authRepo, session),
      );

      feedBloc = FeedBloc(
        getFeedPosts: GetFeedPosts(feedRepository),
        createPost: CreatePost(feedRepository),
        likePost: LikePost(feedRepository),
        editPost: EditPost(feedRepository),
        deletePost: DeletePost(feedRepository),
      );

      getIt.registerFactory<PostComposerBloc>(
        () => PostComposerBloc(createPost: CreatePost(feedRepository)),
      );
    });

    tearDown(() async {
      await GetIt.instance.reset();
    });

    Widget createWidgetUnderTest() {
      return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<FeedBloc>.value(value: feedBloc),
        ],
        child: const MaterialApp(home: Scaffold(body: PostComposerSheet())),
      );
    }

    testWidgets('renders LinkedIn top bar elements with no overflow', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Top bar elements
      expect(find.byIcon(Icons.close_rounded), findsWidgets);
      expect(find.text('Anyone'), findsOneWidget);
      expect(find.text('Add collaborators'), findsOneWidget);
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Post'), findsOneWidget);

      // Dismissible banner
      expect(
        find.text('Collaborative clinical posts are live!'),
        findsOneWidget,
      );

      // Post type pills
      expect(find.text('Update'), findsOneWidget);
      expect(find.text('Clinical Case'), findsOneWidget);
      expect(find.text('Article'), findsOneWidget);
      expect(find.text('Media / Scan'), findsOneWidget);

      // Main input and bottom bar
      expect(find.text('Share your thoughts ...'), findsOneWidget);
      expect(find.text('Proofread'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets(
      'switches to Clinical Case and reveals patient privacy and anonymous toggle',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tap "Clinical Case"
        await tester.tap(find.text('Clinical Case'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Patient Privacy Confirmed'),
          findsOneWidget,
        );
        expect(find.text('Post anonymously'), findsOneWidget);
      },
    );

    testWidgets('entering text enables the Post button and submits post', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final postButtonFinder = find.widgetWithText(ElevatedButton, 'Post');
      final ElevatedButton postButtonBefore = tester.widget(postButtonFinder);
      expect(postButtonBefore.onPressed, isNull);

      // Enter text
      await tester.enterText(
        find.byType(TextField),
        'Important clinical observation on myocardial infarction.',
      );
      await tester.pumpAndSettle();

      final ElevatedButton postButtonAfter = tester.widget(postButtonFinder);
      expect(postButtonAfter.onPressed, isNotNull);

      // Tap Post
      await tester.tap(postButtonFinder);
      await tester.pumpAndSettle();

      expect(feedRepository.createPostCalls, 1);
      expect(
        feedRepository.lastCreatedContent,
        'Important clinical observation on myocardial infarction.',
      );
    });
  });
}
