// BLoC / Cubit state management for Reporting

abstract class ReportingState {
  const ReportingState();
}

class ReportingInitial extends ReportingState {
  const ReportingInitial();
}

class ReportingLoading extends ReportingState {
  const ReportingLoading();
}

class ReportingLoaded extends ReportingState {
  const ReportingLoaded();
}

class ReportingError extends ReportingState {
  final String message;
  const ReportingError(this.message);
}
