import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/home_data.dart';

enum HomeStatus { initial, loading, loaded, refreshing, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final HomeData? data;
  final Failure? error;

  const HomeState({
    this.status = HomeStatus.initial,
    this.data,
    this.error,
  });

  HomeState copyWith({
    HomeStatus? status,
    HomeData? data,
    Failure? error,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
