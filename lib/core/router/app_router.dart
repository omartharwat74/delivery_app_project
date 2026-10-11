import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/home/presentation/bloc/home_cubit.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/register_driver_page.dart';
import '../../features/auth/presentation/pages/registration_pending_page.dart';
import '../../features/auth/presentation/pages/language_page.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/shift_screen.dart';
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
import '../../features/auth/presentation/pages/terms_and_conditions_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
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
        name: RouteNames.home,
        path: RouteNames.driverHome,
        builder: (c, s) => BlocProvider<HomeCubit>(
          create: (context) => di.sl<HomeCubit>(),
          child: const HomePage(),
        ),
      ),
      GoRoute(path: RouteNames.orders, builder: (c, s) => const OrdersScreen()),
      GoRoute(path: RouteNames.wallet, builder: (c, s) => const WalletScreen()),
      GoRoute(
        path: RouteNames.workHours,
        builder: (c, s) => const WorkHoursScreen(),
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
    ],
  );
}
