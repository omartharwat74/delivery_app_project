import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'lookups_state.dart';

class LookupsCubit extends Cubit<LookupsState> {
  final AuthRepository authRepository;

  LookupsCubit({required this.authRepository}) : super(const LookupsState());

  /// Fetches both areas and shifts concurrently
  Future<void> fetchAllLookups() async {
    emit(state.copyWith(status: LookupsStatus.loading, errorMessage: null));

    final results = await Future.wait([
      authRepository.getAreas(),
      authRepository.getShifts(),
    ]);

    final areasResult = results[0];
    final shiftsResult = results[1];

    String? error;
    var currentAreas = state.areas;
    var currentShifts = state.shifts;

    areasResult.fold(
      (failure) => error = failure.message,
      (data) => currentAreas = data as dynamic,
    );

    shiftsResult.fold(
      (failure) => error = error ?? failure.message,
      (data) => currentShifts = data as dynamic,
    );

    emit(state.copyWith(
      status: error != null && currentAreas.isEmpty && currentShifts.isEmpty
          ? LookupsStatus.failure
          : LookupsStatus.success,
      areas: currentAreas,
      shifts: currentShifts,
      errorMessage: error,
    ));
  }

  /// Fetches areas from GET /lookups/areas
  Future<void> fetchAreas() async {
    final result = await authRepository.getAreas();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (areas) => emit(state.copyWith(
        status: LookupsStatus.success,
        areas: areas,
      )),
    );
  }

  /// Fetches shifts from GET /lookups/shifts
  Future<void> fetchShifts() async {
    final result = await authRepository.getShifts();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (shifts) => emit(state.copyWith(
        status: LookupsStatus.success,
        shifts: shifts,
      )),
    );
  }
}
