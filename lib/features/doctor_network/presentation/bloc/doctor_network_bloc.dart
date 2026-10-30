// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/doctor_search_query.dart';
import '../../domain/entities/doctor_search_result.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/usecases/get_public_doctor_profile.dart';
import '../../domain/usecases/search_doctors.dart';
import 'doctor_network_event.dart';
import 'doctor_network_state.dart';

/// Orchestrates the doctor discovery screens (search + public profile).
///
/// The UI dispatches [DoctorNetworkEvent]s and renders [DoctorNetworkState].
/// All network reads go through usecases; the bloc never touches Dio directly.
///
/// Search behavior:
/// - `DoctorSearchQueryChanged` is debounced (400 ms) so typing does not fire
///   one request per keystroke.
/// - `DoctorSearchFiltersChanged` always resets pagination and searches page 1.
/// - `DoctorSearchLoadMoreRequested` is ignored while a page is already being
///   fetched or after the end of the list has been reached.
/// - Pull-to-refresh replaces results (never appends).
class DoctorNetworkBloc extends Bloc<DoctorNetworkEvent, DoctorNetworkState> {
  DoctorNetworkBloc({
    required SearchDoctors searchDoctors,
    required GetPublicDoctorProfile getDoctorProfile,
  }) : _searchDoctors = searchDoctors,
       _getDoctorProfile = getDoctorProfile,
       super(const DoctorNetworkState()) {
    on<DoctorSearchStarted>(_onSearchStarted);
    on<DoctorSearchQueryChanged>(_onSearchQueryChanged);
    on<DoctorSearchFiltersChanged>(_onSearchFiltersChanged);
    on<DoctorSearchLoadMoreRequested>(_onLoadMoreRequested);
    on<DoctorSearchRefreshRequested>(_onRefreshRequested);
    on<DoctorSearchCleared>(_onCleared);
    on<DoctorProfileRequested>(_onProfileRequested);
  }

  static const int _pageSize = 20;
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  final SearchDoctors _searchDoctors;
  final GetPublicDoctorProfile _getDoctorProfile;

  Timer? _debounce;

  /// Kicks off a fresh search after a pause in typing.
  Future<void> _onSearchQueryChanged(
    DoctorSearchQueryChanged event,
    Emitter<DoctorNetworkState> emit,
  ) async {
    _debounce?.cancel();
    final previousQuery = state.query;
    emit(state.copyWith(query: event.query));
    if (event.query.trim() == previousQuery.trim()) {
      // Same effective term (e.g. typing a trailing space) — nothing to fetch.
      return;
    }
    // Dispatch a real event from the timer so the search runs inside a new
    // event handler — emitting from the timer callback directly would violate
    // bloc 9's "emit after handler completed" invariant.
    _debounce = Timer(_debounceDuration, () {
      add(const DoctorSearchStarted());
    });
  }

  Future<void> _onSearchStarted(
    DoctorSearchStarted event,
    Emitter<DoctorNetworkState> emit,
  ) async {
    _debounce?.cancel();
    await _performSearch(emit, page: 1);
  }

  Future<void> _onSearchFiltersChanged(
    DoctorSearchFiltersChanged event,
    Emitter<DoctorNetworkState> emit,
  ) async {
    _debounce?.cancel();
    emit(state.copyWith(filters: event.filters));
    await _performSearch(emit, page: 1);
  }

  Future<void> _onLoadMoreRequested(
    DoctorSearchLoadMoreRequested event,
    Emitter<DoctorNetworkState> emit,
  ) async {
    if (state.hasReachedEnd ||
        state.isLoadingMore ||
        state.isLoading ||
        state.isRefreshing ||
        state.status == DoctorNetworkStatus.initial) {
      return;
    }
    emit(state.copyWith(status: DoctorNetworkStatus.loadingMore));
    await _performSearch(emit, page: state.page + 1);
  }

  Future<void> _onRefreshRequested(
    DoctorSearchRefreshRequested event,
    Emitter<DoctorNetworkState> emit,
  ) async {
    _debounce?.cancel();
    emit(state.copyWith(status: DoctorNetworkStatus.refreshing));
    await _performSearch(emit, page: 1);
  }

  Future<void> _onCleared(
    DoctorSearchCleared event,
    Emitter<DoctorNetworkState> emit,
  ) async {
    _debounce?.cancel();
    emit(const DoctorNetworkState());
  }

  Future<void> _onProfileRequested(
    DoctorProfileRequested event,
    Emitter<DoctorNetworkState> emit,
  ) async {
    emit(
      state.copyWith(
        profileStatus: DoctorNetworkProfileStatus.loading,
        clearProfileError: true,
      ),
    );
    try {
      final profile = await _getDoctorProfile(event.doctorId);
      emit(
        state.copyWith(
          profile: profile,
          profileStatus: DoctorNetworkProfileStatus.loaded,
          clearProfileError: true,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          profileStatus: DoctorNetworkProfileStatus.failure,
          profileError: e,
        ),
      );
    }
  }

  /// Runs one search page. [page] is the 1-based page to fetch.
  ///
  /// Page 1 replaces the current results; later pages append. A fresh first
  /// page shows the full-screen loading state unless the caller already
  /// announced a refresh/load-more status.
  Future<void> _performSearch(
    Emitter<DoctorNetworkState> emit, {
    required int page,
  }) async {
    if (page == 1 && state.status != DoctorNetworkStatus.refreshing) {
      emit(
        state.copyWith(status: DoctorNetworkStatus.loading, clearError: true),
      );
    }
    final query = DoctorSearchQuery(
      search: state.query.trim().isEmpty ? null : state.query.trim(),
      specialty: state.filters.specialty,
      city: state.filters.city,
      experienceMin: state.filters.experienceMin,
      openToOpportunities: state.filters.openToOpportunities,
      page: page,
      pageSize: _pageSize,
    );

    try {
      final result = await _searchDoctors(query);
      _applySearchResult(emit, result, page: page);
    } on Failure catch (e) {
      if (page == 1) {
        emit(state.copyWith(status: DoctorNetworkStatus.failure, error: e));
      } else {
        // Keep the current list; allow a later retry by the user scrolling.
        emit(state.copyWith(status: DoctorNetworkStatus.loaded, error: e));
      }
    }
  }

  void _applySearchResult(
    Emitter<DoctorNetworkState> emit,
    PaginatedResult<DoctorSearchResult> result, {
    required int page,
  }) {
    final isFirstPage = page == 1;
    final results = isFirstPage
        ? result.items
        : [...state.results, ...result.items];
    final reachedEnd = results.length >= result.total;

    emit(
      state.copyWith(
        status: isFirstPage
            ? (result.items.isEmpty
                  ? DoctorNetworkStatus.empty
                  : DoctorNetworkStatus.loaded)
            : DoctorNetworkStatus.loaded,
        results: results,
        page: result.page,
        total: result.total,
        hasReachedEnd: reachedEnd,
        clearError: true,
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
