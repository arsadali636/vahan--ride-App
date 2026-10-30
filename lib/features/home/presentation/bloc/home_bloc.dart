// ignore_for_file: prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required GetHomeData getHomeData})
    : _getHomeData = getHomeData,
      super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  final GetHomeData _getHomeData;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    await _fetchData(emit);
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.refreshing));
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<HomeState> emit) async {
    try {
      final data = await _getHomeData();
      emit(
        state.copyWith(status: HomeStatus.loaded, data: data, clearError: true),
      );
    } on Failure catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, error: e));
    }
  }
}
