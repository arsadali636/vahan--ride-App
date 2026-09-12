// BLoC / Cubit state management for Search

abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  const SearchLoaded();
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
}
