import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_working_hours_usecase.dart';
import '../../domain/usecases/delete_working_hours_usecase.dart';
import '../../domain/usecases/get_working_hours_usecase.dart';
import 'working_hours_state.dart';

class WorkingHoursCubit extends Cubit<WorkingHoursState> {
  final GetWorkingHoursUseCase getWorkingHoursUseCase;
  final AddWorkingHoursUseCase addWorkingHoursUseCase;
  final DeleteWorkingHoursUseCase deleteWorkingHoursUseCase;

  WorkingHoursCubit({
    required this.getWorkingHoursUseCase,
    required this.addWorkingHoursUseCase,
    required this.deleteWorkingHoursUseCase,
  }) : super(WorkingHoursState(
          displayMonth: DateTime(DateTime.now().year, DateTime.now().month, 1),
        ));

  /// Fetch initial working hours data (GET /working-hours)
  Future<void> getWorkingHours() async {
    emit(state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));

    final result = await getWorkingHoursUseCase(const NoParams());

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (entity) {
        DateTime displayMonth = state.displayMonth;
        final fromDate = DateTime.tryParse(entity.windowFrom);
        if (fromDate != null) {
          displayMonth = DateTime(fromDate.year, fromDate.month, 1);
        }

        emit(state.copyWith(
          isLoading: false,
          data: entity,
          displayMonth: displayMonth,
          cardMode: WorkingHoursCardMode.initial,
          clearSelectedDate: true,
          clearPickedStartsAt: true,
          clearPickedEndsAt: true,
          clearErrorMessage: true,
        ));
      },
    );
  }

  /// Change the calendar display month
  void changeMonth(int delta) {
    final nextMonth = DateTime(
      state.displayMonth.year,
      state.displayMonth.month + delta,
      1,
    );
    emit(state.copyWith(displayMonth: nextMonth));
  }

  /// Select a date on the calendar
  void selectDate(DateTime date) {
    // Only allow selecting dates within the 7-day window
    if (!state.isInWindow(date)) {
      return;
    }

    final normalized = DateTime(date.year, date.month, date.day);

    if (state.isBooked(normalized)) {
      // Third State: Booked day view
      final bookedDay = state.bookedDayFor(normalized);
      emit(state.copyWith(
        selectedDate: normalized,
        cardMode: WorkingHoursCardMode.bookedView,
        pickedStartsAt: bookedDay?.startsAt,
        pickedEndsAt: bookedDay?.endsAt,
        clearErrorMessage: true,
      ));
    } else {
      // Second State: New booking state
      emit(state.copyWith(
        selectedDate: normalized,
        cardMode: WorkingHoursCardMode.newBooking,
        pickedStartsAt: state.data?.shift.startsAt ?? '09:00',
        pickedEndsAt: state.data?.shift.endsAt ?? '17:00',
        clearErrorMessage: true,
      ));
    }
  }

  /// Update picked start or end time
  void updatePickedTimes({String? startsAt, String? endsAt}) {
    emit(state.copyWith(
      pickedStartsAt: startsAt ?? state.pickedStartsAt,
      pickedEndsAt: endsAt ?? state.pickedEndsAt,
    ));
  }

  /// Confirm a new booking (POST /working-hours)
  Future<void> confirmBooking() async {
    final selectedDate = state.selectedDate;
    if (selectedDate == null) {
      emit(state.copyWith(errorMessage: 'يرجى تحديد يوم العمل'));
      return;
    }

    final startsAt = state.pickedStartsAt;
    final endsAt = state.pickedEndsAt;

    if (startsAt == null || endsAt == null || startsAt.isEmpty || endsAt.isEmpty) {
      emit(state.copyWith(errorMessage: 'يرجى تحديد وقت البداية والنهاية'));
      return;
    }

    final workDate = _formatDate(selectedDate);

    emit(state.copyWith(
      isActionLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));

    final result = await addWorkingHoursUseCase(AddWorkingHoursParams(
      workDate: workDate,
      startsAt: startsAt,
      endsAt: endsAt,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        ));
      },
      (entity) {
        // Upon 200 OK, update data and switch automatically to Booked Day View State
        emit(state.copyWith(
          isActionLoading: false,
          data: entity,
          cardMode: WorkingHoursCardMode.bookedView,
          successMessage: 'تم حجز موعد العمل بنجاح',
          clearErrorMessage: true,
        ));
      },
    );
  }

  /// Switch card to edit booking mode (Fourth State)
  void enterEditMode() {
    final selectedDate = state.selectedDate;
    if (selectedDate == null) return;

    final bookedDay = state.bookedDayFor(selectedDate);
    if (bookedDay == null || bookedDay.isLocked) return;

    emit(state.copyWith(
      cardMode: WorkingHoursCardMode.editBooking,
      pickedStartsAt: bookedDay.startsAt,
      pickedEndsAt: bookedDay.endsAt,
      clearErrorMessage: true,
    ));
  }

  /// Cancel edit mode and return to booked view
  void cancelEditMode() {
    emit(state.copyWith(
      cardMode: WorkingHoursCardMode.bookedView,
      clearErrorMessage: true,
    ));
  }

  /// Submit edit booking
  Future<void> updateWorkingHours() async {
    // TODO: Integrate Edit Working Hours API when backend is ready
    emit(state.copyWith(
      cardMode: WorkingHoursCardMode.bookedView,
      successMessage: 'تم حفظ التعديل (في انتظار ربط الـ API)',
    ));
  }

  /// Delete a booked day (DELETE /working-hours?work_date=YYYY-MM-DD)
  Future<void> deleteWorkingHours() async {
    final selectedDate = state.selectedDate;
    if (selectedDate == null) return;

    final bookedDay = state.bookedDayFor(selectedDate);
    if (bookedDay == null || bookedDay.isLocked) {
      emit(state.copyWith(
        errorMessage: 'لا يمكن حذف الموعد لأنه مغلق أو غير متاح',
      ));
      return;
    }

    final workDate = _formatDate(selectedDate);

    emit(state.copyWith(
      isActionLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));

    final result = await deleteWorkingHoursUseCase(DeleteWorkingHoursParams(
      workDate: workDate,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isActionLoading: false,
          errorMessage: failure.message,
        ));
      },
      (entity) {
        // Return day to unbooked state
        emit(state.copyWith(
          isActionLoading: false,
          data: entity,
          cardMode: WorkingHoursCardMode.newBooking,
          pickedStartsAt: entity.shift.startsAt,
          pickedEndsAt: entity.shift.endsAt,
          successMessage: 'تم حذف موعد العمل بنجاح',
          clearErrorMessage: true,
        ));
      },
    );
  }

  /// Clear transient error and success messages
  void clearMessages() {
    emit(state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
