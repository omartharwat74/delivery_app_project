import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/working_hours_cubit.dart';
import '../cubit/working_hours_state.dart';
import '../utils/working_hours_formatters.dart';
import '../widgets/booked_day_card.dart';
import '../widgets/edit_booking_card.dart';
import '../widgets/shift_info_widget.dart';
import '../widgets/time_range_picker_widget.dart';
import '../widgets/working_hours_calendar.dart';

class WorkingHoursScreen extends StatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  State<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data on screen load (GET /working-hours)
    context.read<WorkingHoursCubit>().getWorkingHours();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkingHoursCubit>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.onSurface(context),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n?.workingHoursTitle ?? 'مواعيد العمل',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface(context),
            fontFamily: 'ExpoArabic',
          ),
        ),
      ),
      body: BlocConsumer<WorkingHoursCubit, WorkingHoursState>(
        listenWhen: (prev, curr) =>
            curr.errorMessage != null || curr.successMessage != null,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: const TextStyle(fontFamily: 'ExpoArabic'),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            cubit.clearMessages();
          } else if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.successMessage!,
                  style: const TextStyle(fontFamily: 'ExpoArabic'),
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            cubit.clearMessages();
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.data == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Calendar Widget
                        WorkingHoursCalendar(
                          state: state,
                          onDateSelected: (date) => cubit.selectDate(date),
                          onMonthChanged: (delta) => cubit.changeMonth(delta),
                        ),
                        const SizedBox(height: 24),

                        // Center Shift Info Widget
                        ShiftInfoWidget(shift: state.data?.shift),
                        const SizedBox(height: 24),

                        // Card Area based on CardMode
                        _buildCardSection(context, state, cubit),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Button (only shown in newBooking or editBooking)
                _buildBottomButtonSection(context, state, cubit),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardSection(
    BuildContext context,
    WorkingHoursState state,
    WorkingHoursCubit cubit,
  ) {
    switch (state.cardMode) {
      case WorkingHoursCardMode.initial:
        // No card is displayed in initial state
        return const SizedBox.shrink();

      case WorkingHoursCardMode.newBooking:
        final selectedDate = state.selectedDate;
        if (selectedDate == null) return const SizedBox.shrink();
        final dayName = WorkingHoursFormatters.localizedDayName(context, selectedDate);

        return TimeRangePickerWidget(
          dayName: dayName,
          startsAt: state.pickedStartsAt,
          endsAt: state.pickedEndsAt,
          shift: state.data?.shift,
          onTimesChanged: (startsAt, endsAt) {
            cubit.updatePickedTimes(startsAt: startsAt, endsAt: endsAt);
          },
          onError: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg, style: const TextStyle(fontFamily: 'ExpoArabic')),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );

      case WorkingHoursCardMode.bookedView:
        final selectedDate = state.selectedDate;
        if (selectedDate == null) return const SizedBox.shrink();
        final bookedDay = state.bookedDayFor(selectedDate);
        if (bookedDay == null) return const SizedBox.shrink();

        return BookedDayCard(
          day: bookedDay,
          selectedDate: selectedDate,
          onEdit: () => cubit.enterEditMode(),
          onDelete: () => cubit.deleteWorkingHours(),
          isDeleting: state.isActionLoading,
        );

      case WorkingHoursCardMode.editBooking:
        final selectedDate = state.selectedDate;
        if (selectedDate == null) return const SizedBox.shrink();

        return EditBookingCard(
          selectedDate: selectedDate,
          startsAt: state.pickedStartsAt,
          endsAt: state.pickedEndsAt,
          shift: state.data?.shift,
          onTimesChanged: (startsAt, endsAt) {
            cubit.updatePickedTimes(startsAt: startsAt, endsAt: endsAt);
          },
          onCancel: () => cubit.cancelEditMode(),
          onError: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg, style: const TextStyle(fontFamily: 'ExpoArabic')),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
    }
  }

  Widget _buildBottomButtonSection(
    BuildContext context,
    WorkingHoursState state,
    WorkingHoursCubit cubit,
  ) {
    // Only show button in newBooking or editBooking mode
    if (state.cardMode != WorkingHoursCardMode.newBooking &&
        state.cardMode != WorkingHoursCardMode.editBooking) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final isNewBooking = state.cardMode == WorkingHoursCardMode.newBooking;
    final buttonTitle = isNewBooking
        ? (l10n?.confirm ?? 'تأكيد')
        : (l10n?.confirmEdit ?? 'تأكيد التعديل');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: state.isActionLoading
              ? null
              : () {
                  if (isNewBooking) {
                    cubit.confirmBooking();
                  } else {
                    cubit.updateWorkingHours();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: state.isActionLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  buttonTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ExpoArabic',
                  ),
                ),
        ),
      ),
    );
  }
}
