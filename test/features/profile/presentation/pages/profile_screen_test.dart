import 'package:delivery_app_project/core/di/injection_container.dart' as di;
import 'package:delivery_app_project/core/network/auth_event_bus.dart';
import 'package:delivery_app_project/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';
import 'package:delivery_app_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:delivery_app_project/features/auth/presentation/bloc/auth_state.dart';
import 'package:delivery_app_project/features/auth/presentation/widgets/auth_image_upload_box.dart';
import 'package:delivery_app_project/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:delivery_app_project/features/auth/presentation/widgets/document_upload_tile.dart';
import 'package:delivery_app_project/features/auth/presentation/widgets/phone_number_field.dart';
import 'package:delivery_app_project/features/auth/presentation/widgets/vehicle_type_field.dart';
import 'package:delivery_app_project/features/profile/presentation/pages/profile_screen.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../auth/auth_flow_test.dart';

class FakeLocalDataSource implements AuthLocalDataSource {
  int clearSessionCallCount = 0;
  String? savedToken = 'dummy_token';
  DriverModel? savedDriver;

  @override
  Future<void> clearSession() async {
    clearSessionCallCount++;
    savedToken = null;
    savedDriver = null;
  }

  @override
  Future<String?> getToken() async => savedToken;

  @override
  Future<void> saveToken(String token) async {
    savedToken = token;
  }

  @override
  Future<DriverModel?> getDriver() async => savedDriver;

  @override
  Future<void> saveDriver(DriverModel driver) async {
    savedDriver = driver;
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {}
  @override
  Future<void> clearRegistrationToken() async {}
  @override
  Future<void> clearTokens() async {}
  @override
  Future<String> getDriverId() async => '';
  @override
  Future<String> getRefreshToken() async => '';
  @override
  Future<String?> getRegistrationToken() async => null;
  @override
  Future<void> saveDriverId(String driverId) async {}
  @override
  Future<void> saveRefreshToken(String token) async {}
  @override
  Future<void> saveRegistrationToken(String token) async {}
}

void main() {
  late AuthEventBus eventBus;
  late MockAuthRepository authRepo;
  late AuthCubit authCubit;
  late FakeLocalDataSource fakeLocalDs;

  const testDriver = DriverModel(
    id: 1,
    name: 'أحمد محمد',
    phone: '01012345678',
    email: 'ahmed@test.com',
    nationalId: '29501011234567',
    vehicleType: 'motorcycle',
    image: 'https://example.com/avatar.jpg',
    area: DriverAreaModel(id: 10, name: 'المعادي'),
    shift: DriverShiftModel(id: 20, name: 'صباحي', startsAt: '08:00', endsAt: '16:00'),
    profiles: DriverProfilesModel(
      drivingLicense: 'https://example.com/license.jpg',
      vehicleLicense: 'https://example.com/reg.jpg',
      nationalId: 'https://example.com/nid.jpg',
      vehicleFront: 'https://example.com/front.jpg',
    ),
  );

  setUp(() {
    eventBus = AuthEventBus();
    authRepo = MockAuthRepository();
    authCubit = AuthCubit(authRepository: authRepo, authEventBus: eventBus);
    fakeLocalDs = FakeLocalDataSource()..savedDriver = testDriver;

    if (di.sl.isRegistered<AuthLocalDataSource>()) {
      di.sl.unregister<AuthLocalDataSource>();
    }
    di.sl.registerSingleton<AuthLocalDataSource>(fakeLocalDs);
  });

  tearDown(() {
    authCubit.close();
    eventBus.dispose();
  });

  Widget createWidget() {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...AppLocalizations.localizationsDelegates,
      ],
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const ProfileScreen(),
      ),
    );
  }

  testWidgets('renders all driver information as read-only', (tester) async {
    authCubit.emit(const AuthAuthenticated(token: 'dummy_token', driver: testDriver));

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // App Bar Title is always 'البيانات الشخصية'
    expect(find.text('البيانات الشخصية'), findsOneWidget);
    expect(find.text('تعديل البيانات الشخصية'), findsNothing);

    // Profile photo upload box is read-only with no upload icon
    final avatarBoxFinder = find.byType(AuthImageUploadBox);
    expect(avatarBoxFinder, findsOneWidget);
    final avatarBox = tester.widget<AuthImageUploadBox>(avatarBoxFinder);
    expect(avatarBox.readOnly, isTrue);
    expect(avatarBox.showUploadIcon, isFalse);

    // Username field is read-only
    final usernameFinder = find.byWidgetPredicate((w) => w is AuthTextField && w.label == 'اسم المستخدم');
    expect(usernameFinder, findsOneWidget);
    final usernameWidget = tester.widget<AuthTextField>(usernameFinder);
    expect(usernameWidget.readOnly, isTrue);
    expect(usernameWidget.controller.text, 'أحمد محمد');

    // Phone field is read-only and has no change phone button
    final phoneFinder = find.byType(PhoneNumberField);
    expect(phoneFinder, findsOneWidget);
    final phoneWidget = tester.widget<PhoneNumberField>(phoneFinder);
    expect(phoneWidget.readOnly, isTrue);
    expect(find.text('تغيير رقم الجوال'), findsNothing);

    // Email field is read-only
    final emailFinder = find.byWidgetPredicate((w) => w is AuthTextField && w.label == 'البريد الالكتروني');
    expect(emailFinder, findsOneWidget);
    final emailWidget = tester.widget<AuthTextField>(emailFinder);
    expect(emailWidget.readOnly, isTrue);
    expect(emailWidget.controller.text, 'ahmed@test.com');

    // National ID field is read-only
    final nationalIdFinder = find.byWidgetPredicate((w) => w is AuthTextField && w.label == 'الرقم القومي');
    expect(nationalIdFinder, findsOneWidget);
    final nationalIdWidget = tester.widget<AuthTextField>(nationalIdFinder);
    expect(nationalIdWidget.readOnly, isTrue);
    expect(nationalIdWidget.controller.text, '29501011234567');

    // Vehicle Type field is read-only
    final vehicleTypeFinder = find.byType(VehicleTypeField<String>);
    expect(vehicleTypeFinder, findsOneWidget);
    final vehicleTypeWidget = tester.widget<VehicleTypeField<String>>(vehicleTypeFinder);
    expect(vehicleTypeWidget.readOnly, isTrue);
    expect(vehicleTypeWidget.onChanged, isNull);

    // Area and Shift fields are read-only
    final areaFinder = find.byWidgetPredicate((w) => w is AuthTextField && w.label == 'منطقة التوصيل');
    expect(areaFinder, findsOneWidget);
    final areaWidget = tester.widget<AuthTextField>(areaFinder);
    expect(areaWidget.readOnly, isTrue);
    expect(areaWidget.controller.text, 'المعادي');

    final shiftFinder = find.byWidgetPredicate((w) => w is AuthTextField && w.label == 'موعد التوصيل');
    expect(shiftFinder, findsOneWidget);
    final shiftWidget = tester.widget<AuthTextField>(shiftFinder);
    expect(shiftWidget.readOnly, isTrue);
    expect(shiftWidget.controller.text, 'صباحي');

    // All Document tiles are read-only
    final docTiles = tester.widgetList<DocumentUploadTile>(find.byType(DocumentUploadTile)).toList();
    expect(docTiles.length, 4);
    for (final tile in docTiles) {
      expect(tile.readOnly, isTrue);
    }
  });

  testWidgets('NO edit or confirm buttons exist on the screen', (tester) async {
    authCubit.emit(const AuthAuthenticated(token: 'dummy_token', driver: testDriver));

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Verify there is no 'طلب تعديل' or 'تأكيد' bottom button
    expect(find.text('طلب تعديل'), findsNothing);
    expect(find.text('تأكيد'), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'طلب تعديل'), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'تأكيد'), findsNothing);
  });
}
