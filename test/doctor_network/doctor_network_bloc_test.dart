import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/doctor_search_result.dart';
import 'package:doc_connect_app/features/doctor_network/domain/entities/paginated_result.dart';
import 'package:doc_connect_app/features/doctor_network/domain/usecases/get_public_doctor_profile.dart';
import 'package:doc_connect_app/features/doctor_network/domain/usecases/search_doctors.dart';
import 'package:doc_connect_app/features/doctor_network/presentation/bloc/doctor_network_bloc.dart';
import 'package:doc_connect_app/features/doctor_network/presentation/bloc/doctor_network_event.dart';
import 'package:doc_connect_app/features/doctor_network/presentation/bloc/doctor_network_state.dart';

import '../helpers/fake_doctor_network_repository.dart';

DoctorSearchResult _result(String id, String name) {
  final parts = name.split(' ');
  return DoctorSearchResult(
    id: id,
    fullName: name,
    firstName: parts.first,
    lastName: parts.length > 1 ? parts.last : '',
  );
}

PaginatedResult<DoctorSearchResult> _page(
  List<DoctorSearchResult> items, {
  required int total,
  int page = 1,
  int pageSize = 20,
}) {
  return PaginatedResult(
    items: items,
    total: total,
    page: page,
    pageSize: pageSize,
  );
}

/// Waits for a terminal search status, skipping intermediate loading states.
Future<DoctorNetworkState> _awaitSearch(
  DoctorNetworkBloc bloc,
  void Function() trigger, {
  Set<DoctorNetworkStatus> terminal = const {
    DoctorNetworkStatus.loaded,
    DoctorNetworkStatus.empty,
    DoctorNetworkStatus.failure,
  },
}) async {
  final done = bloc.stream
      .firstWhere((s) => terminal.contains(s.status))
      .timeout(const Duration(seconds: 5));
  trigger();
  return done;
}

/// Waits for a terminal public-profile status.
Future<DoctorNetworkState> _awaitProfile(
  DoctorNetworkBloc bloc,
  void Function() trigger,
) async {
  final done = bloc.stream
      .firstWhere((s) =>
          s.profileStatus == DoctorNetworkProfileStatus.loaded ||
          s.profileStatus == DoctorNetworkProfileStatus.failure)
      .timeout(const Duration(seconds: 5));
  trigger();
  return done;
}

void main() {
  late FakeDoctorNetworkRepository repository;
  late DoctorNetworkBloc bloc;

  DoctorNetworkBloc build() {
    return DoctorNetworkBloc(
      searchDoctors: SearchDoctors(repository),
      getDoctorProfile: GetPublicDoctorProfile(repository),
    );
  }

  setUp(() {
    repository = FakeDoctorNetworkRepository();
    bloc = build();
  });

  tearDown(() => bloc.close());

  group('DoctorSearchStarted', () {
    test('loads page 1 and shows results', () async {
      repository.searchPages = [
        _page([_result('d-1', 'Ahmed Ali')], total: 1),
      ];

      final state = await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchStarted());
      });

      expect(state.status, DoctorNetworkStatus.loaded);
      expect(state.results.map((r) => r.id), ['d-1']);
      expect(state.page, 1);
      expect(state.total, 1);
      expect(state.hasReachedEnd, isTrue);
      expect(repository.searchCalls, 1);
      expect(repository.lastQuery!.page, 1);
      expect(repository.lastQuery!.pageSize, 20);
    });

    test('emits empty when no doctors match', () async {
      repository.searchPages = [_page(const [], total: 0)];

      final state = await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchStarted());
      });

      expect(state.status, DoctorNetworkStatus.empty);
      expect(state.results, isEmpty);
    });

    test('emits failure when the search fails', () async {
      repository.searchFailure = const ServerFailure('search down');

      final state = await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchStarted());
      });

      expect(state.status, DoctorNetworkStatus.failure);
      expect(state.error, isA<ServerFailure>());
      expect(state.results, isEmpty);
    });
  });

  group('DoctorSearchQueryChanged', () {
    test('debounces typing and searches once with the final term', () async {
      repository.searchPages = [
        _page([_result('d-1', 'Ahmed Ali')], total: 1),
      ];

      final state = await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchQueryChanged('A'));
        bloc.add(const DoctorSearchQueryChanged('Ah'));
        bloc.add(const DoctorSearchQueryChanged('Ahmed'));
      });

      expect(repository.searchCalls, 1);
      expect(repository.lastQuery!.search, 'Ahmed');
      expect(state.status, DoctorNetworkStatus.loaded);
      expect(state.query, 'Ahmed');
    });
  });

  group('DoctorSearchFiltersChanged', () {
    test('resets pagination and searches page 1 with the new filters',
        () async {
      repository.searchPages = [
        _page([_result('d-1', 'Ahmed Ali')], total: 1),
      ];

      await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchStarted());
      });

      final state = await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchFiltersChanged(
          DoctorNetworkFilters(specialty: 'Cardiology', city: 'Mumbai'),
        ));
      });

      expect(repository.searchCalls, 2);
      expect(repository.lastQuery!.page, 1);
      expect(repository.lastQuery!.specialty, 'Cardiology');
      expect(repository.lastQuery!.city, 'Mumbai');
      expect(state.filters.specialty, 'Cardiology');
      expect(state.results.map((r) => r.id), ['d-1']);
    });
  });

  group('DoctorSearchLoadMoreRequested', () {
    test('appends the next page and marks the end of the list', () async {
      final page1 = _page(
        List.generate(20, (i) => _result('d-$i', 'Doctor $i')),
        total: 25,
      );
      final page2 = _page(
        List.generate(5, (i) => _result('e-$i', 'Extra $i')),
        total: 25,
        page: 2,
      );
      repository.searchPages = [page1, page2];

      await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchStarted());
      });

      final state = await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchLoadMoreRequested());
      });

      expect(state.status, DoctorNetworkStatus.loaded);
      expect(state.results.length, 25);
      expect(state.page, 2);
      expect(state.hasReachedEnd, isTrue);
      expect(repository.searchCalls, 2);
      expect(repository.lastQuery!.page, 2);
    });

    test('is ignored when the end of the list was reached', () async {
      repository.searchPages = [
        _page([_result('d-1', 'Ahmed Ali')], total: 1),
      ];

      await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchStarted());
      });

      bloc.add(const DoctorSearchLoadMoreRequested());
      bloc.add(const DoctorSearchLoadMoreRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(repository.searchCalls, 1);
    });

    test('is ignored while a load-more is already in flight', () async {
      repository.searchDelay = const Duration(milliseconds: 200);
      final page1 = _page(
        List.generate(20, (i) => _result('d-$i', 'Doctor $i')),
        total: 40,
      );
      final page2 = _page(
        List.generate(20, (i) => _result('e-$i', 'Extra $i')),
        total: 40,
        page: 2,
      );
      repository.searchPages = [page1, page2];

      await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchStarted());
      });

      bloc.add(const DoctorSearchLoadMoreRequested());
      // Immediately request again while page 2 is still in flight.
      bloc.add(const DoctorSearchLoadMoreRequested());

      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(repository.searchCalls, 2);
    });

    test('keeps existing results when a load-more page fails', () async {
      final page1 = _page(
        List.generate(20, (i) => _result('d-$i', 'Doctor $i')),
        total: 40,
      );
      repository.searchPages = [page1];

      await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchStarted());
      });

      // From now on, page 2 throws.
      repository.searchFailure = const ServerFailure('page 2 exploded');

      final state = await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchLoadMoreRequested());
      });

      expect(state.status, DoctorNetworkStatus.loaded);
      expect(state.results.length, 20);
      expect(state.error, isA<ServerFailure>());
    });
  });

  group('DoctorSearchRefreshRequested', () {
    test('replaces results instead of appending', () async {
      final page1 = _page(
        List.generate(20, (i) => _result('d-$i', 'Doctor $i')),
        total: 40,
      );
      final page2 = _page(
        List.generate(20, (i) => _result('e-$i', 'Extra $i')),
        total: 40,
        page: 2,
      );
      repository.searchPages = [page1, page2];

      await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchStarted());
      });
      await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchLoadMoreRequested());
      });

      final state = await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchRefreshRequested());
      });

      expect(repository.searchCalls, 3);
      expect(state.status, DoctorNetworkStatus.loaded);
      expect(state.results.length, 20);
      expect(state.page, 1);
      expect(repository.lastQuery!.page, 1);
    });
  });

  group('DoctorSearchCleared', () {
    test('resets to the initial discovery state', () async {
      repository.searchPages = [
        _page([_result('d-1', 'Ahmed Ali')], total: 1),
      ];
      await _awaitSearch(bloc, () {
        bloc.add(const DoctorSearchStarted());
      });

      bloc.add(const DoctorSearchCleared());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.status, DoctorNetworkStatus.initial);
      expect(bloc.state.results, isEmpty);
      expect(bloc.state.query, '');
      expect(bloc.state.filters.isEmpty, isTrue);
    });
  });

  group('DoctorProfileRequested', () {
    test('loads and exposes the public profile', () async {
      final state = await _awaitProfile(bloc, () {
        bloc.add(const DoctorProfileRequested('doc-42'));
      });

      expect(repository.profileCalls, 1);
      expect(repository.lastDoctorId, 'doc-42');
      expect(state.profileStatus, DoctorNetworkProfileStatus.loaded);
      expect(state.profile?.id, 'doc-42');
    });

    test('emits failure when the profile cannot be loaded', () async {
      repository.profileFailure = const NotFoundFailure('Doctor not found');

      final state = await _awaitProfile(bloc, () {
        bloc.add(const DoctorProfileRequested('missing'));
      });

      expect(state.profileStatus, DoctorNetworkProfileStatus.failure);
      expect(state.profileError, isA<NotFoundFailure>());
      expect(state.profile, isNull);
    });
  });
}
