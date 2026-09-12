import 'package:equatable/equatable.dart';

import 'doctor_network_state.dart';

/// Events for the doctor discovery screens.
///
/// Connection/follow APIs are not present in the current OpenAPI contract, so
/// no connection/follow events exist — they will be added in a later prompt
/// when the backend documents those endpoints.
sealed class DoctorNetworkEvent extends Equatable {
  const DoctorNetworkEvent();

  @override
  List<Object?> get props => [];
}

/// Kick off the first search (page 1) with the current query/filters.
class DoctorSearchStarted extends DoctorNetworkEvent {
  const DoctorSearchStarted();
}

/// The search text changed. Debounced by the bloc (one API call per burst of
/// typing).
class DoctorSearchQueryChanged extends DoctorNetworkEvent {
  final String query;

  const DoctorSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter values changed. Always resets pagination and searches page 1.
class DoctorSearchFiltersChanged extends DoctorNetworkEvent {
  final DoctorNetworkFilters filters;

  const DoctorSearchFiltersChanged(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// The user scrolled near the bottom — fetch the next page.
class DoctorSearchLoadMoreRequested extends DoctorNetworkEvent {
  const DoctorSearchLoadMoreRequested();
}

/// Pull-to-refresh: refetch page 1 and replace the results.
class DoctorSearchRefreshRequested extends DoctorNetworkEvent {
  const DoctorSearchRefreshRequested();
}

/// Clear the search and return to the discovery prompt.
class DoctorSearchCleared extends DoctorNetworkEvent {
  const DoctorSearchCleared();
}

/// Load a doctor's public profile for the detail screen.
class DoctorProfileRequested extends DoctorNetworkEvent {
  final String doctorId;

  const DoctorProfileRequested(this.doctorId);

  @override
  List<Object?> get props => [doctorId];
}
