import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app_project/core/network/auth_event_bus.dart';
import 'package:delivery_app_project/core/router/app_router.dart';
import 'package:delivery_app_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:delivery_app_project/features/auth/presentation/pages/login_page.dart';
import 'package:delivery_app_project/features/auth/presentation/pages/splash_screen.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

import '../../features/auth/auth_flow_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthEventBus eventBus;
  late MockAuthRepository mockAuth;
  late AuthCubit authCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'driver_app_locale': 'ar'});
    eventBus = AuthEventBus();
    mockAuth = MockAuthRepository();
    authCubit = AuthCubit(authRepository: mockAuth, authEventBus: eventBus);
    AppRouter.listenToAuthEvents(eventBus: eventBus);
  });

  tearDown(() {
    AppRouter.dispose();
    authCubit.close();
  });

  group('AppRouter Tests', () {
    test('navigatorKey is properly initialized', () {
      expect(AppRouter.navigatorKey, isNotNull);
    });

    testWidgets('redirectToLogin and 401 event trigger redirection to LoginPage', (tester) async {
      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: MaterialApp.router(
            locale: const Locale('ar'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: AppRouter.router,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);

      // Trigger global redirectToLogin
      AppRouter.redirectToLogin();
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);

      // Trigger 401 via eventBus
      eventBus.emitUnauthorized();
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);

      // Settle any remaining splash timer
      await tester.pump(const Duration(milliseconds: 1600));
    });
  });
}
