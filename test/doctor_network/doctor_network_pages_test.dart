import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:doc_connect_app/app/app_router.dart';
import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/doctor_search_result.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/paginated_result.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/public_doctor_profile.dart';
import 'package:doc_connect_app/features/doctor_network/domain/usecases/get_public_doctor_profile.dart';
import 'package:doc_connect_app/features/doctor_network/domain/usecases/search_doctors.dart';
import 'package:doc_connect_app/features/doctor_network/presentation/bloc/doctor_network_bloc.dart';
import 'package:doc_connect_app/features/doctor_network/presentation/pages/doctor_public_profile_page.dart';
import 'package:doc_connect_app/features/doctor_network/presentation/pages/doctor_search_page.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_verification_status.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/location.dart';

import '../helpers/fake_doctor_network_repository.dart';

DoctorSearchResult _result({
  String id = 'd-1',
  String name = 'Ahmed Ali',
  String? headline,
  String? specialty,
  Location? location,
  double experienceYears = 0,
  bool openToOpportunities = false,
}) {
  final parts = name.split(' ');
  return DoctorSearchResult(
    id: id,
    fullName: name,
    firstName: parts.first,
    lastName: parts.length > 1 ? parts.last : '',
    headline: headline,
    primarySpecializationId: specialty,
    professionalLocation: location,
    experienceYears: experienceYears,
    openToOpportunities: openToOpportunities,
  );
}

PaginatedResult<DoctorSearchResult> _page(
  List<DoctorSearchResult> items, {
  required int total,
}) {
  return PaginatedResult(items: items, total: total, page: 1, pageSize: 20);
}

void main() {
  late FakeDoctorNetworkRepository repository;
  late DoctorNetworkBloc bloc;

  DoctorNetworkBloc buildBloc() {
    return DoctorNetworkBloc(
      searchDoctors: SearchDoctors(repository),
      getDoctorProfile: GetPublicDoctorProfile(repository),
    );
  }

  /// Advances through the bloc handler's async chain and the resulting frame.
  Future<void> pumpBloc(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpSearch(WidgetTester tester, {GoRouter? router}) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    bloc = buildBloc();
    if (router != null) {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();
    } else {
      await tester.pumpWidget(MaterialApp(home: DoctorSearchPage(bloc: bloc)));
      await tester.pump();
    }
  }

  Future<void> searchFor(WidgetTester tester, String term) async {
    await tester.enterText(find.byType(TextField).first, term);
    // Let the debounce timer fire, then apply the loaded state.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  Future<void> pumpProfile(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    bloc = buildBloc();
    await tester.pumpWidget(
      MaterialApp(
        home: DoctorPublicProfilePage(doctorId: 'doc-42', bloc: bloc),
      ),
    );
    await tester.pump();
  }

  setUp(() {
    repository = FakeDoctorNetworkRepository();
  });

  group('DoctorSearchPage', () {
    testWidgets('shows the discovery prompt before any search', (tester) async {
      await pumpSearch(tester);

      expect(find.text('Find doctors'), findsOneWidget);
      expect(find.text('Discover doctors'), findsOneWidget);
    });

    testWidgets('searches after a debounce and renders result cards', (
      tester,
    ) async {
      repository.searchPages = [
        _page([
          _result(
            headline: 'Senior Consultant',
            specialty: 'Cardiology',
            location: const Location(city: 'Mumbai', state: 'Maharashtra'),
            experienceYears: 12,
            openToOpportunities: true,
          ),
        ], total: 1),
      ];
      await pumpSearch(tester);

      await searchFor(tester, 'Ahmed');

      expect(repository.searchCalls, 1);
      expect(repository.lastQuery?.search, 'Ahmed');
      expect(find.text('Ahmed Ali'), findsOneWidget);
      expect(find.text('Senior Consultant'), findsOneWidget);
      expect(find.text('Cardiology • Mumbai, Maharashtra'), findsOneWidget);
      expect(find.text('12 yrs experience'), findsOneWidget);
      expect(find.text('Open to opportunities'), findsOneWidget);
    });

    testWidgets('shows an empty state when nothing matches', (tester) async {
      repository.searchPages = [_page(const [], total: 0)];
      await pumpSearch(tester);

      await searchFor(tester, 'zzz');

      expect(find.text('No doctors found'), findsOneWidget);
      expect(find.text('Try changing your search or filters.'), findsOneWidget);
    });

    testWidgets('shows a failure state and recovers on retry', (tester) async {
      repository.searchFailure = const ServerFailure('search is down');
      await pumpSearch(tester);

      await searchFor(tester, 'Ahmed');

      expect(find.text('Could not search doctors'), findsOneWidget);
      expect(find.text('search is down'), findsOneWidget);

      repository.searchFailure = null;
      repository.searchPages = [
        _page([_result(headline: 'Senior Consultant')], total: 1),
      ];
      await tester.tap(find.text('Try again'));
      await pumpBloc(tester);

      expect(find.text('Ahmed Ali'), findsOneWidget);
      expect(repository.searchCalls, 2);
    });

    testWidgets('navigates to the public profile when a card is tapped', (
      tester,
    ) async {
      repository.searchPages = [
        _page([_result()], total: 1),
      ];
      final router = GoRouter(
        initialLocation: AppRouter.doctorNetworkRoute,
        routes: [
          GoRoute(
            path: AppRouter.doctorNetworkRoute,
            builder: (context, state) => DoctorSearchPage(bloc: bloc),
          ),
          GoRoute(
            path: AppRouter.doctorPublicProfileRoute,
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text('PROFILE-${state.pathParameters['doctorId']}'),
              ),
            ),
          ),
        ],
      );
      await pumpSearch(tester, router: router);

      await searchFor(tester, 'Ahmed');
      await tester.tap(find.text('Ahmed Ali'));
      await tester.pumpAndSettle();

      expect(find.text('PROFILE-d-1'), findsOneWidget);
    });

    testWidgets('applies filters from the bottom sheet', (tester) async {
      repository.searchPages = [
        _page([_result(specialty: 'Cardiology')], total: 1),
      ];
      await pumpSearch(tester);

      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Specialty'),
        'Cardiology',
      );
      await tester.tap(find.text('Apply filters'));
      await tester.pumpAndSettle();

      expect(find.text('Filters · 1'), findsOneWidget);
      expect(repository.lastQuery?.specialty, 'Cardiology');
      expect(find.text('Ahmed Ali'), findsOneWidget);
    });

    testWidgets('clear all returns to the discovery prompt', (tester) async {
      await pumpSearch(tester);

      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      expect(find.text('Discover doctors'), findsOneWidget);
      expect(repository.searchCalls, 0);
    });
  });

  group('DoctorPublicProfilePage', () {
    testWidgets('shows a loader while the profile loads', (tester) async {
      repository.profileDelay = const Duration(milliseconds: 500);
      await pumpProfile(tester);

      expect(find.text('Doctor profile'), findsOneWidget);
      expect(find.text('Loading profile…'), findsOneWidget);

      await pumpBloc(tester);
    });

    testWidgets('shows a failure view and a snackbar when loading fails', (
      tester,
    ) async {
      repository.profileFailure = const ServerFailure('profile exploded');
      await pumpProfile(tester);
      await pumpBloc(tester);

      expect(find.text('Could not load this doctor'), findsOneWidget);
      // The message is rendered in the error view and in the SnackBar.
      expect(find.text('profile exploded'), findsWidgets);
    });

    testWidgets('renders the loaded profile sections', (tester) async {
      repository.profile = const PublicDoctorProfile(
        id: 'doc-42',
        fullName: 'Ada Lovelace',
        firstName: 'Ada',
        lastName: 'Lovelace',
        headline: 'Senior Cardiologist',
        about: 'Heart surgery and preventive cardiology.',
        primarySpecializationId: 'Cardiology',
        clinicalInterests: ['Heart surgery', 'Research'],
        professionalLocation: Location(city: 'Mumbai', state: 'Maharashtra'),
        experienceYears: 12,
        openToOpportunities: true,
        verificationStatus: DoctorVerificationStatus.verified,
        isVerified: true,
      );
      await pumpProfile(tester);
      await pumpBloc(tester);

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('Verified doctor'), findsOneWidget);
      expect(find.text('Senior Cardiologist'), findsOneWidget);
      expect(find.text('Mumbai, Maharashtra'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(
        find.text('Heart surgery and preventive cardiology.'),
        findsOneWidget,
      );
      expect(find.text('Specialization'), findsOneWidget);
      expect(find.text('Experience'), findsOneWidget);
      expect(find.text('12 years'), findsOneWidget);
      expect(find.text('Clinical interests'), findsOneWidget);
      expect(find.text('Heart surgery'), findsOneWidget);
      expect(find.text('Research'), findsOneWidget);
    });

    testWidgets('shows coming-soon messages for the network actions', (
      tester,
    ) async {
      repository.profile = const PublicDoctorProfile(
        id: 'doc-42',
        fullName: 'Ada Lovelace',
        firstName: 'Ada',
        lastName: 'Lovelace',
      );
      await pumpProfile(tester);
      await pumpBloc(tester);

      await tester.tap(find.text('Connect'));
      await tester.pump();
      expect(find.text('Connections is not available yet'), findsOneWidget);

      await tester.tap(find.text('Follow'));
      await tester.pump();
      expect(find.text('Following is not available yet'), findsOneWidget);

      await tester.tap(find.text('Message'));
      await tester.pump();
      expect(find.text('Messaging is not available yet'), findsOneWidget);
    });
  });
}
