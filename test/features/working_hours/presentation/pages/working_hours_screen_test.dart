import 'package:dartz/dartz.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/working_hours/domain/entities/working_hours_entity.dart';
import 'package:delivery_app_project/features/working_hours/domain/repositories/working_hours_repository.dart';
import 'package:delivery_app_project/features/working_hours/domain/usecases/add_working_hours_usecase.dart';
import 'package:delivery_app_project/features/working_hours/domain/usecases/delete_working_hours_usecase.dart';
import 'package:delivery_app_project/features/working_hours/domain/usecases/get_working_hours_usecase.dart';
import 'package:delivery_app_project/features/working_hours/presentation/cubit/working_hours_cubit.dart';
import 'package:delivery_app_project/features/working_hours/presentation/pages/working_hours_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_app_project/l10n/app_localizations.dart';

class FakeTestRepository implements WorkingHoursRepository {
  final WorkingHoursEntity entity;
  FakeTestRepository(this.entity);

  @override
  Future<Either<Failure, WorkingHoursEntity>> getWorkingHours() async {
    return Right(entity);
  }

  @override
  Future<Either<Failure, WorkingHoursEntity>> addWorkingHours({
    required String workDate,
    required String startsAt,
    required String endsAt,
  }) async {
    return Right(entity);
  }

  @override
  Future<Either<Failure, WorkingHoursEntity>> deleteWorkingHours({
    required String workDate,
  }) async {
    return Right(entity);
  }
}

void main() {
  const testEntity = WorkingHoursEntity(
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

  Widget createTestWidget(
    WidgetTester tester,
    WorkingHoursCubit cubit, {
    Locale locale = const Locale('ar'),
    ThemeMode themeMode = ThemeMode.light,
  }) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...AppLocalizations.localizationsDelegates,
      ],
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: Directionality(
        textDirection: locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: BlocProvider<WorkingHoursCubit>.value(
          value: cubit,
          child: const WorkingHoursScreen(),
        ),
      ),
    );
  }

  testWidgets('State 1 (Initial): displays shift info, calendar, and NO bottom button or detail card', (tester) async {
    final fakeRepo = FakeTestRepository(testEntity);
    final cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepo),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepo),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepo),
    );

    await tester.pumpWidget(createTestWidget(tester, cubit));
    await tester.pumpAndSettle();

    // Title
    expect(find.text('مواعيد العمل'), findsOneWidget);

    // Center Shift Info
    expect(find.text('فترة العمل المحددة'), findsOneWidget);
    expect(find.text('09:00 AM - 05:00 PM'), findsOneWidget);

    // No detail card buttons or bottom button
    expect(find.text('تأكيد'), findsNothing);
    expect(find.text('تأكيد التعديل'), findsNothing);
    expect(find.text('تعديل الموعد'), findsNothing);
    expect(find.text('حذف'), findsNothing);
  });

  testWidgets('State 2 (New booking): tapping unbooked date shows day name, time fields, and bottom تأكيد button', (tester) async {
    final fakeRepo = FakeTestRepository(testEntity);
    final cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepo),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepo),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepo),
    );

    await tester.pumpWidget(createTestWidget(tester, cubit));
    await tester.pumpAndSettle();

    // Tap day 20 (unbooked day within 18-24 window)
    final day20Finder = find.text('20');
    expect(day20Finder, findsOneWidget);
    await tester.tap(day20Finder);
    await tester.pumpAndSettle();

    // Time fields "من" and "الى" appear
    expect(find.text('من'), findsOneWidget);
    expect(find.text('الى'), findsOneWidget);

    // Bottom red button "تأكيد" is visible
    expect(find.text('تأكيد'), findsOneWidget);
    expect(find.text('تأكيد التعديل'), findsNothing);
  });

  testWidgets('State 3 (Booked day): tapping booked day shows card with edit and delete, NO bottom button', (tester) async {
    final fakeRepo = FakeTestRepository(testEntity);
    final cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepo),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepo),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepo),
    );

    await tester.pumpWidget(createTestWidget(tester, cubit));
    await tester.pumpAndSettle();

    // Tap day 18 (booked day in testEntity)
    final day18Finder = find.text('18');
    expect(day18Finder, findsOneWidget);
    await tester.tap(day18Finder);
    await tester.pumpAndSettle();

    // Card shows formatted booking time and date (DD/MM/YYYY)
    expect(find.text('18/11/2026'), findsOneWidget);
    expect(find.text('09:00 AM - 12:00 PM'), findsOneWidget);

    // Card buttons appear
    expect(find.text('تعديل الموعد'), findsOneWidget);
    expect(find.text('حذف'), findsOneWidget);

    // CRITICAL: Bottom red button MUST BE HIDDEN
    expect(find.text('تأكيد'), findsNothing);
    expect(find.text('تأكيد التعديل'), findsNothing);
  });

  testWidgets('State 3 (Locked day): locked day displays warning and disables edit/delete actions', (tester) async {
    final fakeRepo = FakeTestRepository(testEntity);
    final cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepo),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepo),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepo),
    );

    await tester.pumpWidget(createTestWidget(tester, cubit));
    await tester.pumpAndSettle();

    // Tap day 19 (is_locked == true)
    final day19Finder = find.text('19');
    expect(day19Finder, findsOneWidget);
    await tester.tap(day19Finder);
    await tester.pumpAndSettle();

    // Shows lock warning
    expect(find.text('الموعد مغلق للتعديل أو الحذف (أقل من 6 ساعات)'), findsOneWidget);

    // Tap 'تعديل الموعد' should do nothing because it is locked
    await tester.tap(find.text('تعديل الموعد'));
    await tester.pumpAndSettle();

    // Still in booked view, not in edit mode
    expect(find.text('تأكيد التعديل'), findsNothing);
  });

  testWidgets('State 4 (Edit booking): tapping edit on unlocked day switches to edit mode with bottom button', (tester) async {
    final fakeRepo = FakeTestRepository(testEntity);
    final cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepo),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepo),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepo),
    );

    await tester.pumpWidget(createTestWidget(tester, cubit));
    await tester.pumpAndSettle();

    // Tap day 18 (unlocked)
    await tester.tap(find.text('18'));
    await tester.pumpAndSettle();

    // Tap 'تعديل الموعد'
    await tester.tap(find.text('تعديل الموعد'));
    await tester.pumpAndSettle();

    // Bottom button now changes to 'تأكيد التعديل'
    expect(find.text('تأكيد التعديل'), findsOneWidget);
    expect(find.text('تأكيد'), findsNothing);

    // Cancel edit returns to booked view
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد التعديل'), findsNothing);
    expect(find.text('تعديل الموعد'), findsOneWidget);
  });

  testWidgets('Calendar navigation: right arrow advances month, left arrow goes back, and weekdays are Sun to Sat LTR', (tester) async {
    final fakeRepo = FakeTestRepository(testEntity);
    final cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepo),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepo),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepo),
    );

    await tester.pumpWidget(createTestWidget(tester, cubit));
    await tester.pumpAndSettle();

    // Initial month is November (نوفمبر) from testEntity (windowFrom: 2026-11-18)
    expect(find.text('نوفمبر'), findsOneWidget);

    // Verify Sun is to the left of Sat in LTR
    final sunOffset = tester.getTopLeft(find.text('Sun'));
    final satOffset = tester.getTopLeft(find.text('Sat'));
    expect(sunOffset.dx < satOffset.dx, isTrue);

    // Tap right button (chevron_right_rounded): advances to December (ديسمبر)
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text('ديسمبر'), findsOneWidget);
    expect(find.text('نوفمبر'), findsNothing);

    // Tap left button (chevron_left_rounded): goes back to November (نوفمبر)
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.text('نوفمبر'), findsOneWidget);

    // Tap left button again: goes to October (أكتوبر)
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.text('أكتوبر'), findsOneWidget);
  });

  testWidgets('Time picker: tapping "من" opens Cupertino bottom sheet modal and confirming updates the time', (tester) async {
    final fakeRepo = FakeTestRepository(testEntity);
    final cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepo),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepo),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepo),
    );

    await tester.pumpWidget(createTestWidget(tester, cubit));
    await tester.pumpAndSettle();

    // Tap day 20 (unbooked) to enter State 2
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();

    // Tap "من" time field
    await tester.tap(find.text('من'));
    await tester.pumpAndSettle();

    // Verify CupertinoDatePicker is displayed in the modal
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    expect(find.text('تحديد وقت البداية (من)'), findsOneWidget);
    expect(find.text('إلغاء'), findsOneWidget);

    // Tap "تأكيد" in the modal bottom sheet
    final modalConfirmBtn = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.widgetWithText(TextButton, 'تأكيد'),
    );
    await tester.tap(modalConfirmBtn);
    await tester.pumpAndSettle();

    // Modal is closed
    expect(find.byType(CupertinoDatePicker), findsNothing);
  });

  testWidgets('English localization: displays English texts for title, shift info, calendar, and actions', (tester) async {
    final fakeRepo = FakeTestRepository(testEntity);
    final cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepo),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepo),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepo),
    );

    await tester.pumpWidget(createTestWidget(tester, cubit, locale: const Locale('en')));
    await tester.pumpAndSettle();

    // English Title
    expect(find.text('Working Hours'), findsOneWidget);

    // English Shift Period label
    expect(find.text('Specified Working Period'), findsOneWidget);

    // English Month name
    expect(find.text('November'), findsOneWidget);

    // Tap day 20 (unbooked)
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();

    // English labels in time picker
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);

    // Tap booked day 18
    await tester.tap(find.text('18'));
    await tester.pumpAndSettle();

    // English action buttons in booked card
    expect(find.text('Edit Appointment'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('Dark mode: renders without error and applies dark theme tokens', (tester) async {
    final fakeRepo = FakeTestRepository(testEntity);
    final cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepo),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepo),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepo),
    );

    await tester.pumpWidget(createTestWidget(
      tester,
      cubit,
      themeMode: ThemeMode.dark,
    ));
    await tester.pumpAndSettle();

    // Screen renders properly in dark mode
    expect(find.text('مواعيد العمل'), findsOneWidget);
    expect(find.text('فترة العمل المحددة'), findsOneWidget);

    // Tap day 20 to test time range picker in dark mode
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    expect(find.text('من'), findsOneWidget);
    expect(find.text('الى'), findsOneWidget);

    // Open bottom sheet in dark mode
    await tester.tap(find.text('من'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
  });

  testWidgets('Cupertino time picker: displays AM and PM even when app is in Arabic', (tester) async {
    final fakeRepo = FakeTestRepository(testEntity);
    final cubit = WorkingHoursCubit(
      getWorkingHoursUseCase: GetWorkingHoursUseCase(fakeRepo),
      addWorkingHoursUseCase: AddWorkingHoursUseCase(fakeRepo),
      deleteWorkingHoursUseCase: DeleteWorkingHoursUseCase(fakeRepo),
    );

    await tester.pumpWidget(createTestWidget(tester, cubit, locale: const Locale('ar')));
    await tester.pumpAndSettle();

    // Tap day 20 (unbooked) to enter State 2
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();

    // Tap "من" time field
    await tester.tap(find.text('من'));
    await tester.pumpAndSettle();

    // Verify AM and PM are present and ص or م are NOT present in the picker
    expect(find.text('AM'), findsWidgets);
    expect(find.text('PM'), findsWidgets);
    expect(find.text('ص'), findsNothing);
    expect(find.text('م'), findsNothing);
  });
}
