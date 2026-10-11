import 'package:equatable/equatable.dart';

import '../../data/models/area_model.dart';
import '../../data/models/shift_model.dart';

enum LookupsStatus { initial, loading, success, failure }

class LookupsState extends Equatable {
  final LookupsStatus status;
  final List<AreaModel> areas;
  final List<ShiftModel> shifts;
  final String? errorMessage;

  const LookupsState({
    this.status = LookupsStatus.initial,
    this.areas = const [],
    this.shifts = const [],
    this.errorMessage,
  });

  bool get isLoading => status == LookupsStatus.loading;
  bool get isLoadingAreas => isLoading;
  bool get isLoadingShifts => isLoading;
  bool get isSuccess => status == LookupsStatus.success;
  bool get isFailure => status == LookupsStatus.failure;

  LookupsState copyWith({
    LookupsStatus? status,
    List<AreaModel>? areas,
    List<ShiftModel>? shifts,
    String? errorMessage,
  }) {
    return LookupsState(
      status: status ?? this.status,
      areas: areas ?? this.areas,
      shifts: shifts ?? this.shifts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, areas, shifts, errorMessage];
}
