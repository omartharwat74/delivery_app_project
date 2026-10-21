import 'package:dartz/dartz.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/working_hours/domain/entities/working_hours_entity.dart';
import 'package:delivery_app_project/features/working_hours/domain/repositories/working_hours_repository.dart';
import 'package:delivery_app_project/features/working_hours/domain/usecases/add_working_hours_usecase.dart';
import 'package:delivery_app_project/features/working_hours/domain/usecases/delete_working_hours_usecase.dart';
import 'package:delivery_app_project/features/working_hours/domain/usecases/get_working_hours_usecase.dart';
import 'package:delivery_app_project/features/working_hours/domain/usecases/update_working_hours_usecase.dart';
import 'package:delivery_app_project/features/working_hours/presentation/cubit/working_hours_cubit.dart';
import 'package:delivery_app_project/features/working_hours/presentation/cubit/working_hours_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWorkingHoursRepository implements WorkingHoursRepository {
  WorkingHoursEntity? mockData;
  bool shouldFail = false;
  Failure failure = const ServerFailure('Server error');

  @override
  Future<Either<Failure, WorkingHoursEntity>> getWorkingHours() async {
    if (shouldFail) return Left(failure);
    return Right(mockData ?? _defaultEntity);
  }

  @override
  Future<Either<Failure, WorkingHoursEntity>> addWorkingHours({
    required String workDate,
    required String startsAt,
    required String endsAt,
  }) async {
    if (shouldFail) return Left(failure);

    final updatedDays = List<WorkingHourDay>.from(mockData?.days ?? _defaultEntity.days)
      ..add(WorkingHourDay(
        workDate: workDate,
        startsAt: startsAt,
        endsAt: endsAt,
        isLocked: false,
      ));

    mockData = WorkingHoursEntity(
      shift: mockData?.shift ?? _defaultEntity.shift,
      days: updatedDays,
      windowFrom: mockData?.windowFrom ?? _defaultEntity.windowFrom,
      windowTo: mockData?.windowTo ?? _defaultEntity.windowTo,
    );

    return Right(mockData!);
  }

  @override
  Future<Either<Failure, WorkingHoursEntity>> deleteWorkingHours({
    required String workDate,
  }) async {
    if (shouldFail) return Left(failure);

    final updatedDays = List<WorkingHourDay>.from(mockData?.days ?? _defaultEntity.days)
      ..removeWhere((d) => d.workDate == workDate);

    mockData = WorkingHoursEntity(
      shift: mockData?.shift ?? _defaultEntity.shift,
      days: updatedDays,
      windowFrom: mockData?.windowFrom ?? _defaultEntity.windowFrom,
      windowTo: mockData?.windowTo ?? _defaultEntity.windowTo,
    );

    return Right(mockData!);
  }

  @override
  Future<Either<Failure, WorkingHoursEntity>> updateWorkingHours({
    required String workDate,
    required String startsAt,
    required String endsAt,
  }) async {
    if (shouldFail) return Left(failure);

    final updatedDays = List<WorkingHourDay>.from(mockData?.days ?? _defaultEntity.days);
    final index = updatedDays.indexWhere((d) => d.workDate == workDate);
    if (index != -1) {
      updatedDays[index] = WorkingHourDay(
        workDate: workDate,
        startsAt: startsAt,
        endsAt: endsAt,
        isLocked: updatedDays[index].isLocked,
      );
    }

    mockData = WorkingHoursEntity(
      shift: mockData?.shift ?? _defaultEntity.shift,
      days: updatedDays,
      windowFrom: mockData?.windowFrom ?? _defaultEntity.windowFrom,
      windowTo: mockData?.windowTo ?? _defaultEntity.windowTo,
    );

    return Right(mockData!);
  }

  static const _defaultEntity = WorkingHoursEntity(
    shift: ShiftEntity(startsAt: '09:00', endsAt: '17:00'),
    days: [
      WorkingHourDay(
        workDate: '2026-11-18',
        startsAt: '09:00',
        endsAt: '12:00',
        isLocked: false,
      ),
      WorkingHourDay(
        workDate: '2026-11-19',
        startsAt: '10:00',
        endsAt: '14:00',
        isLocked: true,
      ),
    ],
    windowFrom: '2026-11-18',
    windowTo: '2026-11-24',
  );
}

void main() {
  late FakeWorkingHoursRepository fakeRepository;
  late WorkingHoursCubit cubit;

  setUp(() {
    fakeRepository = FakeWorkingHoursRepository();
    cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepository),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepository),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepository),
      updateWorkingHoursUseCase: UpdateWorkingHoursUseCase(fakeRepository),
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('WorkingHoursCubit', () {
    test('initial state has correct defaults', () {
      expect(cubit.state.cardMode, WorkingHoursCardMode.initial);
      expect(cubit.state.selectedDate, isNull);
      expect(cubit.state.data, isNull);
      expect(cubit.state.isLoading, false);
    });

    test('getWorkingHours populates state with server data on success', () async {
      await cubit.getWorkingHours();

      expect(cubit.state.isLoading, false);
      expect(cubit.state.data, isNotNull);
      expect(cubit.state.data!.shift.startsAt, '09:00');
      expect(cubit.state.data!.days.length, 2);
      expect(cubit.state.cardMode, WorkingHoursCardMode.initial);
      expect(cubit.state.selectedDate, isNull);
    });

    test('getWorkingHours emits errorMessage on failure (e.g. 404/422)', () async {
      fakeRepository.shouldFail = true;
      fakeRepository.failure = const ValidationFailure('فترة العمل غير صالحة');

      await cubit.getWorkingHours();

      expect(cubit.state.isLoading, false);
      expect(cubit.state.errorMessage, 'فترة العمل غير صالحة');
    });

    test('selectDate on unbooked day inside 7-day window switches to newBooking mode', () async {
      await cubit.getWorkingHours();

      final unbookedDate = DateTime(2026, 11, 20); // within 18-24 window, not in days
      cubit.selectDate(unbookedDate);

      expect(cubit.state.cardMode, WorkingHoursCardMode.newBooking);
      expect(cubit.state.selectedDate, unbookedDate);
      expect(cubit.state.pickedStartsAt, '09:00');
      expect(cubit.state.pickedEndsAt, '17:00');
    });

    test('selectDate outside 7-day window does nothing', () async {
      await cubit.getWorkingHours();

      final outsideDate = DateTime(2026, 11, 10);
      cubit.selectDate(outsideDate);

      expect(cubit.state.cardMode, WorkingHoursCardMode.initial);
      expect(cubit.state.selectedDate, isNull);
    });

    test('selectDate on booked day inside 7-day window switches to bookedView mode', () async {
      await cubit.getWorkingHours();

      final bookedDate = DateTime(2026, 11, 18); // Booked day in fake data
      cubit.selectDate(bookedDate);

      expect(cubit.state.cardMode, WorkingHoursCardMode.bookedView);
      expect(cubit.state.selectedDate, bookedDate);
      expect(cubit.state.pickedStartsAt, '09:00');
      expect(cubit.state.pickedEndsAt, '12:00');
    });

    test('confirmBooking sends POST and switches automatically to bookedView on 200 OK', () async {
      await cubit.getWorkingHours();

      final newDate = DateTime(2026, 11, 21);
      cubit.selectDate(newDate);
      cubit.updatePickedTimes(startsAt: '10:00', endsAt: '14:00');

      await cubit.confirmBooking();

      expect(cubit.state.cardMode, WorkingHoursCardMode.bookedView);
      expect(cubit.state.data!.days.any((d) => d.workDate == '2026-11-21'), isTrue);
      expect(cubit.state.successMessage, 'تم حجز موعد العمل بنجاح');
    });

    test('confirmBooking handles server validation error 422 cleanly', () async {
      await cubit.getWorkingHours();

      final newDate = DateTime(2026, 11, 21);
      cubit.selectDate(newDate);

      fakeRepository.shouldFail = true;
      fakeRepository.failure = const ValidationFailure('الوقت خارج حدود الشيفت الأساسي');

      await cubit.confirmBooking();

      expect(cubit.state.errorMessage, 'الوقت خارج حدود الشيفت الأساسي');
      expect(cubit.state.isActionLoading, false);
    });

    test('deleteWorkingHours calls DELETE and returns day to unbooked state on 200 OK', () async {
      await cubit.getWorkingHours();

      final bookedDate = DateTime(2026, 11, 18);
      cubit.selectDate(bookedDate);
      expect(cubit.state.cardMode, WorkingHoursCardMode.bookedView);

      await cubit.deleteWorkingHours();

      expect(cubit.state.cardMode, WorkingHoursCardMode.newBooking);
      expect(cubit.state.data!.days.any((d) => d.workDate == '2026-11-18'), isFalse);
      expect(cubit.state.successMessage, 'تم حذف موعد العمل بنجاح');
    });

    test('deleteWorkingHours on locked day (is_locked == true) is rejected without API call', () async {
      await cubit.getWorkingHours();

      final lockedDate = DateTime(2026, 11, 19); // is_locked == true
      cubit.selectDate(lockedDate);

      await cubit.deleteWorkingHours();

      expect(cubit.state.errorMessage, contains('مغلق'));
      // Day is still in list
      expect(cubit.state.data!.days.any((d) => d.workDate == '2026-11-19'), isTrue);
    });

    test('enterEditMode switches to editBooking cardMode and pre-fills booked times', () async {
      await cubit.getWorkingHours();

      final bookedDate = DateTime(2026, 11, 18);
      cubit.selectDate(bookedDate);

      cubit.enterEditMode();

      expect(cubit.state.cardMode, WorkingHoursCardMode.editBooking);
      expect(cubit.state.pickedStartsAt, '09:00');
      expect(cubit.state.pickedEndsAt, '12:00');
    });

    test('enterEditMode on locked day does nothing', () async {
      await cubit.getWorkingHours();

      final lockedDate = DateTime(2026, 11, 19);
      cubit.selectDate(lockedDate);

      cubit.enterEditMode();

      expect(cubit.state.cardMode, WorkingHoursCardMode.bookedView);
    });

    test('updateWorkingHours successfully updates slot on 200 OK and switches back to bookedView', () async {
      await cubit.getWorkingHours();

      final bookedDate = DateTime(2026, 11, 18);
      cubit.selectDate(bookedDate);
      cubit.enterEditMode();

      cubit.updatePickedTimes(startsAt: '11:00', endsAt: '15:00');

      await cubit.updateWorkingHours();

      expect(cubit.state.cardMode, WorkingHoursCardMode.bookedView);
      expect(cubit.state.isActionLoading, false);
      expect(cubit.state.successMessage, 'تم تعديل موعد العمل بنجاح');

      final updatedDay = cubit.state.bookedDayFor(bookedDate);
      expect(updatedDay?.startsAt, '11:00');
      expect(updatedDay?.endsAt, '15:00');
    });

    test('updateWorkingHours handles 422 validation error and retains edit state', () async {
      await cubit.getWorkingHours();

      final bookedDate = DateTime(2026, 11, 18);
      cubit.selectDate(bookedDate);
      cubit.enterEditMode();
      cubit.updatePickedTimes(startsAt: '08:00', endsAt: '12:00');

      fakeRepository.shouldFail = true;
      fakeRepository.failure = const ValidationFailure('لا يمكن تعديل الموعد إذا تبقّى أقل من 6 ساعات على بدايته.');

      await cubit.updateWorkingHours();

      expect(cubit.state.cardMode, WorkingHoursCardMode.editBooking);
      expect(cubit.state.isActionLoading, false);
      expect(cubit.state.errorMessage, 'لا يمكن تعديل الموعد إذا تبقّى أقل من 6 ساعات على بدايته.');
      expect(cubit.state.pickedStartsAt, '08:00');
      expect(cubit.state.pickedEndsAt, '12:00');
    });

    test('updateWorkingHours handles 422 shift boundary error and retains edit state', () async {
      await cubit.getWorkingHours();

      final bookedDate = DateTime(2026, 11, 18);
      cubit.selectDate(bookedDate);
      cubit.enterEditMode();

      fakeRepository.shouldFail = true;
      fakeRepository.failure = const ValidationFailure('الوقت المحدد خارج حدود الشيفت الأساسي');

      await cubit.updateWorkingHours();

      expect(cubit.state.cardMode, WorkingHoursCardMode.editBooking);
      expect(cubit.state.isActionLoading, false);
      expect(cubit.state.errorMessage, 'الوقت المحدد خارج حدود الشيفت الأساسي');
    });

    test('updateWorkingHours handles 404 not found error and retains edit state', () async {
      await cubit.getWorkingHours();

      final bookedDate = DateTime(2026, 11, 18);
      cubit.selectDate(bookedDate);
      cubit.enterEditMode();

      fakeRepository.shouldFail = true;
      fakeRepository.failure = const NotFoundFailure('لا يوجد موعد لهذا اليوم.');

      await cubit.updateWorkingHours();

      expect(cubit.state.cardMode, WorkingHoursCardMode.editBooking);
      expect(cubit.state.isActionLoading, false);
      expect(cubit.state.errorMessage, 'لا يوجد موعد لهذا اليوم.');
    });

    test('updateWorkingHours on locked day (is_locked == true) is rejected without API call', () async {
      await cubit.getWorkingHours();

      final lockedDate = DateTime(2026, 11, 19);
      cubit.selectDate(lockedDate);

      // Force call updateWorkingHours on locked day
      await cubit.updateWorkingHours();

      expect(cubit.state.errorMessage, contains('مغلق'));
      expect(cubit.state.isActionLoading, false);
    });

    test('updateWorkingHours without selected date emits error', () async {
      await cubit.getWorkingHours();

      await cubit.updateWorkingHours();

      expect(cubit.state.errorMessage, 'يرجى تحديد يوم العمل');
    });
  });
}
