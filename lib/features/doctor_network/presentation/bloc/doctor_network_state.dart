import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/doctor_search_result.dart';
import '../../domain/entities/public_doctor_profile.dart';

/// Search lifecycle of the doctor discovery screen.
enum DoctorNetworkStatus {
  /// Nothing searched yet — show the discovery prompt.
  initial,

  /// Initial search is in flight.
  loading,

  /// Results are on screen (may also be carrying the error from a failed
  /// load-more while keeping existing results).
  loaded,

  /// The next page is being fetched (list stays visible).
  loadingMore,

  /// Pull-to-refresh is in flight while showing stale content.
  refreshing,

  /// The last search matched no doctors.
  empty,

  /// The last search failed.
  failure,
}

/// Lifecycle of the public doctor profile request.
enum DoctorNetworkProfileStatus {
  initial,
  loading,
  loaded,
  failure,
}

/// Active filter values for doctor discovery.
///
/// Kept separate from the results so a filter change always starts a fresh
/// search (page 1) instead of appending to previously filtered results.
class DoctorNetworkFilters extends Equatable {
  final String? specialty;
  final String? city;
  final double? experienceMin;
  final bool? openToOpportunities;

  const DoctorNetworkFilters({
    this.specialty,
    this.city,
    this.experienceMin,
    this.openToOpportunities,
  });

  bool get isEmpty =>
      (specialty == null || specialty!.isEmpty) &&
      (city == null || city!.isEmpty) &&
      experienceMin == null &&
      openToOpportunities == null;

  DoctorNetworkFilters copyWith({
    String? specialty,
    String? city,
    double? experienceMin,
    bool? openToOpportunities,
  }) {
    return DoctorNetworkFilters(
      specialty: specialty ?? this.specialty,
      city: city ?? this.city,
      experienceMin: experienceMin ?? this.experienceMin,
      openToOpportunities: openToOpportunities ?? this.openToOpportunities,
    );
  }

  @override
  List<Object?> get props =>
      [specialty, city, experienceMin, openToOpportunities];
}

/// Single source of truth for the doctor discovery (search + public profile)
/// screens.
class DoctorNetworkState extends Equatable {
  final DoctorNetworkStatus status;
  final String query;
  final DoctorNetworkFilters filters;
  final List<DoctorSearchResult> results;
  final int page;
  final int total;
  final bool hasReachedEnd;
  final Failure? error;

  final DoctorNetworkProfileStatus profileStatus;
  final PublicDoctorProfile? profile;
  final Failure? profileError;

  const DoctorNetworkState({
    this.status = DoctorNetworkStatus.initial,
    this.query = '',
    this.filters = const DoctorNetworkFilters(),
    this.results = const [],
    this.page = 1,
    this.total = 0,
    this.hasReachedEnd = false,
    this.error,
    this.profileStatus = DoctorNetworkProfileStatus.initial,
    this.profile,
    this.profileError,
  });

  bool get isLoading => status == DoctorNetworkStatus.loading;

  bool get isLoadingMore => status == DoctorNetworkStatus.loadingMore;

  bool get isRefreshing => status == DoctorNetworkStatus.refreshing;

  DoctorNetworkState copyWith({
    DoctorNetworkStatus? status,
    String? query,
    DoctorNetworkFilters? filters,
    List<DoctorSearchResult>? results,
    int? page,
    int? total,
    bool? hasReachedEnd,
    Failure? error,
    bool clearError = false,
    DoctorNetworkProfileStatus? profileStatus,
    PublicDoctorProfile? profile,
    Failure? profileError,
    bool clearProfileError = false,
  }) {
    return DoctorNetworkState(
      status: status ?? this.status,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      results: results ?? this.results,
      page: page ?? this.page,
      total: total ?? this.total,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      error: clearError ? null : (error ?? this.error),
      profileStatus: profileStatus ?? this.profileStatus,
      profile: profile ?? this.profile,
      profileError:
          clearProfileError ? null : (profileError ?? this.profileError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        filters,
        results,
        page,
        total,
        hasReachedEnd,
        error,
        profileStatus,
        profile,
        profileError,
      ];
}
