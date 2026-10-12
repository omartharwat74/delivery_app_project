import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app_project/core/network/auth_event_bus.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';
import 'package:delivery_app_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:delivery_app_project/features/home/presentation/bloc/home_cubit.dart';
import 'package:delivery_app_project/features/home/presentation/pages/home_page.dart';
import 'package:delivery_app_project/features/orders/presentation/bloc/active_order_cubit.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

import '../../../auth/auth_flow_test.dart';
import '../bloc/home_cubit_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHomeRepository homeRepository;
  late MockAuthRepository authRepository;
  late SharedPreferences prefs;
  late HomeCubit homeCubit;
  late AuthCubit authCubit;
  late ActiveOrderCubit activeOrderCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'delivery_app_device_id': 'test-device-id'});
    prefs = await SharedPreferences.getInstance();
    homeRepository = MockHomeRepository();
    authRepository = MockAuthRepository();
    homeCubit = HomeCubit(
      homeRepository: homeRepository,
      sharedPreferences: prefs,
      locationService: MockLocationService(),
      notificationService: MockNotificationService(),
    );
    authCubit = AuthCubit(authRepository: authRepository, authEventBus: AuthEventBus());
    activeOrderCubit = ActiveOrderCubit();
  });

  tearDown(() {
    homeCubit.close();
    authCubit.close();
    activeOrderCubit.close();
  });

  Widget buildHomePage({Locale locale = const Locale('ar')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>.value(value: homeCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<ActiveOrderCubit>.value(value: activeOrderCubit),
        ],
        child: const HomePage(),
      ),
    );
  }

  testWidgets('renders toggle button and calls toggleAvailability on tap', (tester) async {
    homeRepository.cachedDriver = const DriverModel(
      id: 1,
      name: 'Captain Jack',
      phone: '01012345678',
      isOnline: false,
    );

    await tester.pumpWidget(buildHomePage());
    await tester.pumpAndSettle();

    // Toggle button should be found
    final toggleFinder = find.byType(AnimatedContainer);
    expect(toggleFinder, findsOneWidget);

    // Initial state is offline (isOnline: false)
    expect(homeCubit.state.isOnline, isFalse);

    // Tap toggle button to go online
    await tester.tap(toggleFinder);
    await tester.pump();

    // Cubit should have toggled to true
    expect(homeCubit.state.isOnline, isTrue);
  });
}
