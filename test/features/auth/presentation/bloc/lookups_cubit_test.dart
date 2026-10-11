import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/auth/data/models/area_model.dart';
import 'package:delivery_app_project/features/auth/data/models/shift_model.dart';
import 'package:delivery_app_project/features/auth/presentation/bloc/lookups_cubit.dart';
import 'package:delivery_app_project/features/auth/presentation/bloc/lookups_state.dart';

import '../../auth_flow_test.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late LookupsCubit lookupsCubit;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    lookupsCubit = LookupsCubit(authRepository: mockAuthRepository);
  });

  tearDown(() {
    lookupsCubit.close();
  });

  test('initial state has empty areas, empty shifts, and status initial', () {
    expect(lookupsCubit.state.status, equals(LookupsStatus.initial));
    expect(lookupsCubit.state.areas, isEmpty);
    expect(lookupsCubit.state.shifts, isEmpty);
  });

  test('fetchAllLookups emits loading then success with areas and shifts', () async {
    const mockAreas = [
      AreaModel(id: 1, name: 'المعادي'),
      AreaModel(id: 2, name: 'مدينة نصر'),
    ];
    const mockShifts = [
      ShiftModel(id: 1, name: 'صباحي', startsAt: '08:00', endsAt: '16:00'),
    ];

    mockAuthRepository.getAreasResult = const Right(mockAreas);
    mockAuthRepository.getShiftsResult = const Right(mockShifts);

    final expectedStates = [
      const LookupsState(status: LookupsStatus.loading),
      const LookupsState(
        status: LookupsStatus.success,
        areas: mockAreas,
        shifts: mockShifts,
      ),
    ];

    expectLater(lookupsCubit.stream, emitsInOrder(expectedStates));

    await lookupsCubit.fetchAllLookups();
  });

  test('fetchAllLookups emits failure when getAreas fails', () async {
    mockAuthRepository.getAreasResult = const Left(ServerFailure('Failed to load areas'));
    mockAuthRepository.getShiftsResult = const Right([]);

    final expectedStates = [
      const LookupsState(status: LookupsStatus.loading),
      const LookupsState(
        status: LookupsStatus.failure,
        errorMessage: 'Failed to load areas',
      ),
    ];

    expectLater(lookupsCubit.stream, emitsInOrder(expectedStates));

    await lookupsCubit.fetchAllLookups();
  });
}
