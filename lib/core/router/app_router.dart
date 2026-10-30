import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart' as di;
import '../network/auth_event_bus.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/orders/presentation/bloc/active_order_cubit.dart';
import '../../features/orders/presentation/bloc/orders_cubit.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/register_driver_page.dart';
import '../../features/auth/presentation/pages/registration_pending_page.dart';
import '../../features/auth/presentation/pages/blocked_account_page.dart';
import '../../features/auth/presentation/pages/language_page.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/shift_screen.dart';
import '../../features/working_hours/presentation/cubit/working_hours_cubit.dart';
import '../../features/working_hours/presentation/pages/working_hours_screen.dart';
import '../../features/orders/presentation/pages/orders_screen.dart';
import '../../features/wallet/presentation/pages/wallet_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/settings/presentation/pages/change_phone_screen.dart';
import '../../features/settings/presentation/pages/verify_phone_otp_screen.dart';
import '../../features/settings/presentation/pages/verify_phone_otp_args.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/reviews/presentation/bloc/reviews_cubit.dart';
import '../../features/profile/presentation/pages/notifications_screen.dart';
import '../../features/profile/presentation/pages/reviews_screen.dart';
import '../../features/profile/presentation/pages/support_screen.dart';
import '../../features/support/presentation/pages/full_screen_image_viewer_screen.dart';
import '../../features/auth/presentation/pages/terms_and_conditions_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'app_root_navigator');

  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  static StreamSubscription<void>? _unauthorizedSubscription;
  static StreamSubscription<String?>? _blockedSubscription;

  /// Global method to clear the navigation stack and redirect immediately to Login
  static void redirectToLogin() {
    final nav = navigatorKey.currentState;
    if (nav != null) {
      while (nav.canPop()) {
        nav.pop();
      }
    }
    router.go(RouteNames.login);
  }

  /// Global method to clear the navigation stack and redirect immediately to Blocked screen
  static void redirectToBlocked([String? message]) {
    final nav = navigatorKey.currentState;
    if (nav != null) {
      while (nav.canPop()) {
        nav.pop();
      }
    }
    router.go(RouteNames.blocked, extra: message);
  }

  /// Listens to unauthorized 401 and 403 blocked events globally
  static void listenToAuthEvents({AuthEventBus? eventBus}) {
    _unauthorizedSubscription?.cancel();
    _blockedSubscription?.cancel();
    final bus = eventBus ?? di.sl<AuthEventBus>();
    _unauthorizedSubscription = bus.onUnauthorized.listen((_) {
      redirectToLogin();
    });
    _blockedSubscription = bus.onAccountBlocked.listen((message) {
      // In case of 403, keep driver inside the app on Home screen with warning banner.
      // Do not force logout or redirect away.
    });
  }

  static void dispose() {
    _unauthorizedSubscription?.cancel();
    _unauthorizedSubscription = null;
    _blockedSubscription?.cancel();
    _blockedSubscription = null;
  }

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    observers: [routeObserver],
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(path: RouteNames.splash, builder: (c, s) => const SplashScreen()),
      GoRoute(
        path: RouteNames.language,
        builder: (c, s) => const LanguagePage(),
      ),
      GoRoute(path: RouteNames.login, builder: (c, s) => const LoginPage()),
      GoRoute(
        path: RouteNames.otp,
        builder: (c, s) => OtpPage(phoneNumber: s.extra as String?),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (c, s) => RegisterDriverPage(phone: s.extra as String?),
      ),
      GoRoute(
        path: RouteNames.pending,
        builder: (c, s) => const RegistrationPendingPage(),
      ),
      GoRoute(
        path: RouteNames.blocked,
        builder: (c, s) => BlockedAccountPage(message: s.extra as String?),
      ),
      GoRoute(
        name: RouteNames.home,
        path: RouteNames.driverHome,
        builder: (c, s) => MultiBlocProvider(
          providers: [
            BlocProvider<HomeCubit>(
              create: (context) => di.sl<HomeCubit>(),
            ),
            BlocProvider<ActiveOrderCubit>.value(
              value: di.sl<ActiveOrderCubit>(),
            ),
          ],
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: RouteNames.orders,
        builder: (c, s) => BlocProvider<OrdersCubit>(
          create: (_) => di.sl<OrdersCubit>()..loadOrders(),
          child: const OrdersScreen(),
        ),
      ),
      GoRoute(path: RouteNames.wallet, builder: (c, s) => const WalletScreen()),
      GoRoute(
        path: RouteNames.workHours,
        builder: (c, s) => BlocProvider<WorkingHoursCubit>(
          create: (context) => di.sl<WorkingHoursCubit>(),
          child: const WorkingHoursScreen(),
        ),
      ),
      GoRoute(
        name: RouteNames.settings,
        path: RouteNames.settings,
        builder: (c, s) => MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>.value(
              value: di.sl<SettingsCubit>()..initSettings(),
            ),
            BlocProvider<HomeCubit>(
              create: (context) => di.sl<HomeCubit>()..initHome(),
            ),
          ],
          child: const SettingsScreen(),
        ),
        routes: [
          GoRoute(
            name: RouteNames.changePhone,
            path: 'change-phone',
            builder: (c, s) => BlocProvider<SettingsCubit>.value(
              value: di.sl<SettingsCubit>(),
              child: const ChangePhoneScreen(),
            ),
          ),
          GoRoute(
            name: RouteNames.verifyPhoneOtp,
            path: 'otp',
            builder: (c, s) {
              final args = s.extra is VerifyPhoneOtpArgs
                  ? s.extra as VerifyPhoneOtpArgs
                  : VerifyPhoneOtpArgs(
                      phoneNumber: s.extra is String ? s.extra as String : '',
                    );
              return BlocProvider<SettingsCubit>.value(
                value: di.sl<SettingsCubit>(),
                child: VerifyPhoneOtpScreen(args: args),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (c, s) => BlocProvider<NotificationsCubit>(
          create: (_) => di.sl<NotificationsCubit>()..loadNotifications(),
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.reviews,
        builder: (c, s) => BlocProvider<ReviewsCubit>(
          create: (_) => di.sl<ReviewsCubit>()..loadReviews(),
          child: const ReviewsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.support,
        builder: (c, s) => const SupportScreen(),
      ),
      GoRoute(
        path: RouteNames.termsAndConditions,
        builder: (c, s) => BlocProvider<SettingsCubit>.value(
          value: di.sl<SettingsCubit>()..loadTerms(),
          child: const TermsAndConditionsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (c, s) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.fullScreenImageViewer,
        builder: (c, s) {
          final imageUrl = (s.extra as String?) ?? '';
          return FullScreenImageViewerScreen(imageUrl: imageUrl);
        },
      ),
    ],
  );
}
