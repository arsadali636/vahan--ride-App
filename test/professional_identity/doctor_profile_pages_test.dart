import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:doc_connect_app/app/app_router.dart';
import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_qualification.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/add_experience_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/add_qualification_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/add_registration_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/create_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/delete_experience_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/delete_qualification_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/get_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/list_experiences_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/list_qualifications_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/list_registrations_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/update_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/upload_profile_photo_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/presentation/bloc/doctor_profile_bloc.dart';
import 'package:doc_connect_app/features/professional_identity/presentation/pages/doctor_profile_page.dart';
import 'package:doc_connect_app/features/professional_identity/presentation/pages/edit_profile_page.dart';
import 'package:doc_connect_app/features/professional_identity/presentation/pages/profile_completion_page.dart';

import '../helpers/fake_doctor_profile_repository.dart';
import '../helpers/fake_session_service.dart';

void main() {
  late FakeSessionService session;
  late FakeDoctorProfileRepository repository;

  DoctorProfileBloc buildBloc() {
    return DoctorProfileBloc(
      sessionService: session,
      getDoctorProfile: GetDoctorProfile(repository),
      createDoctorProfile: CreateDoctorProfile(repository),
      updateDoctorProfile: UpdateDoctorProfile(repository),
      uploadProfilePhoto: UploadProfilePhoto(repository),
      listQualifications: ListQualifications(repository),
      addQualification: AddQualification(repository),
      deleteQualification: DeleteQualification(repository),
      listRegistrations: ListRegistrations(repository),
      addRegistration: AddRegistration(repository),
      listExperiences: ListExperiences(repository),
      addExperience: AddExperience(repository),
      deleteExperience: DeleteExperience(repository),
    );
  }

  /// Advances through the bloc handler's async chain and the resulting frame.
  Future<void> pumpBloc(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  setUp(() {
    session = FakeSessionService();
    repository = FakeDoctorProfileRepository();
  });

  group('DoctorProfilePage', () {
    late DoctorProfileBloc bloc;

    Future<void> pumpPage(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      bloc = buildBloc();
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DoctorProfileBloc>.value(
            value: bloc,
            child: DoctorProfilePage(bloc: bloc),
          ),
        ),
      );
      // Two frames: the first builds the page (initState adds the load event),
      // the second renders the loading state.
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows the loader while loading', (tester) async {
      repository.getDelay = const Duration(milliseconds: 500);
      await pumpPage(tester);

      expect(find.text('Loading profile…'), findsOneWidget);
      expect(find.text('My profile'), findsOneWidget);

      await pumpBloc(tester);
    });

    testWidgets('shows the completion prompt when the profile is missing', (
      tester,
    ) async {
      repository.getFailure = NotFoundFailure('no profile');

      await pumpPage(tester);
      await pumpBloc(tester);

      expect(find.text('Complete your profile'), findsOneWidget);
    });

    testWidgets('shows a failure view when loading fails', (tester) async {
      repository.getFailure = ServerFailure('boom');

      await pumpPage(tester);
      await pumpBloc(tester);

      expect(find.text('Could not load your profile'), findsOneWidget);
      expect(find.text('boom'), findsOneWidget);
    });

    testWidgets('renders the loaded profile details', (tester) async {
      await pumpPage(tester);
      await pumpBloc(tester);

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Unverified'), findsOneWidget);
      expect(find.text('Profile photo'), findsOneWidget);
      expect(find.text('Qualifications'), findsOneWidget);
      expect(find.text('Registrations'), findsOneWidget);
      expect(find.text('Experience'), findsOneWidget);
    });

    testWidgets('renders sub-resources when present', (tester) async {
      repository.qualifications = const [
        DoctorQualification(
          id: 'q-1',
          degree: 'MBBS',
          institution: 'GMC',
          year: 2012,
        ),
      ];

      await pumpPage(tester);
      await pumpBloc(tester);

      expect(find.text('MBBS'), findsOneWidget);
      expect(find.textContaining('GMC'), findsOneWidget);
    });
  });

  group('ProfileCompletionPage', () {
    late DoctorProfileBloc bloc;

    Future<void> pumpPage(WidgetTester tester, {GoRouter? router}) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      bloc = buildBloc();
      if (router != null) {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      } else {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<DoctorProfileBloc>.value(
              value: bloc,
              child: ProfileCompletionPage(bloc: bloc),
            ),
          ),
        );
      }
      await tester.pump();
    }

    testWidgets('renders the create form', (tester) async {
      await pumpPage(tester);

      expect(find.text('Complete your profile'), findsOneWidget);
      expect(find.text('Create profile'), findsOneWidget);
    });

    testWidgets('validates required names before submitting', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Create profile'));
      await tester.pump();

      expect(find.text('Required'), findsNWidgets(2));
      expect(repository.getCalls, 0);
    });

    testWidgets('creates the profile and navigates on success', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      bloc = buildBloc();
      final router = GoRouter(
        initialLocation: AppRouter.completeProfileRoute,
        routes: [
          GoRoute(
            path: AppRouter.completeProfileRoute,
            builder: (_, _) => BlocProvider<DoctorProfileBloc>.value(
              value: bloc,
              child: ProfileCompletionPage(bloc: bloc),
            ),
          ),
          GoRoute(
            path: AppRouter.profileRoute,
            builder: (_, _) =>
                const Scaffold(body: Center(child: Text('PROFILE'))),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'First name *'),
        'Ada',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Last name *'),
        'Lovelace',
      );
      await tester.tap(find.text('Create profile'));
      await pumpBloc(tester);

      expect(await session.getProfileCreated(), isTrue);
      expect(find.text('PROFILE'), findsOneWidget);
    });
  });

  group('EditProfilePage', () {
    late DoctorProfileBloc bloc;

    GoRouter buildEditRouter() {
      return GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.push(AppRouter.editProfileRoute),
                  child: const Text('Open editor'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: AppRouter.editProfileRoute,
            builder: (_, _) => EditProfilePage(bloc: bloc),
          ),
          GoRoute(
            path: AppRouter.profileRoute,
            builder: (_, _) =>
                const Scaffold(body: Center(child: Text('PROFILE'))),
          ),
        ],
      );
    }

    Future<void> openEditor(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      bloc = buildBloc();
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: buildEditRouter()),
      );
      await tester.pump();
      await tester.tap(find.text('Open editor'));
      // Two frames: process the push, then render the pushed page.
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows the loader while loading', (tester) async {
      repository.getDelay = const Duration(milliseconds: 500);
      await openEditor(tester);

      expect(find.text('Loading profile…'), findsOneWidget);

      await pumpBloc(tester);
    });

    testWidgets('shows a prompt when there is no profile', (tester) async {
      repository.getFailure = NotFoundFailure('no profile');

      await openEditor(tester);
      await pumpBloc(tester);

      expect(find.text('No profile to edit yet.'), findsOneWidget);
      expect(find.text('Create profile'), findsOneWidget);
    });

    testWidgets('pre-fills the form and saves changes', (tester) async {
      await openEditor(tester);
      await pumpBloc(tester);

      expect(find.text('Save changes'), findsOneWidget);
      final firstNameField = find.widgetWithText(TextFormField, 'First name *');
      expect(
        tester.widget<TextFormField>(firstNameField).controller?.text,
        'Ada',
      );

      await tester.tap(find.text('Save changes'));
      await pumpBloc(tester);

      expect(find.text('Profile updated'), findsOneWidget);
      expect(find.text('Open editor'), findsOneWidget);
    });
  });
}
