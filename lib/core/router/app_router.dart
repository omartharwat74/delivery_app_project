import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/profile/presentation/bloc/profile_bloc.dart';

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
import '../../features/profile/presentation/pages/settings_screen.dart';
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
      GoRoute(path: RouteNames.driverHome, builder: (c, s) => const HomePage()),
      GoRoute(path: RouteNames.orders, builder: (c, s) => const OrdersScreen()),
      GoRoute(path: RouteNames.wallet, builder: (c, s) => const WalletScreen()),
      GoRoute(
        path: RouteNames.workHours,
        builder: (c, s) => const WorkHoursScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (c, s) => BlocProvider<ProfileBloc>(
          create: (context) => di.sl<ProfileBloc>(),
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (c, s) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.reviews,
        builder: (c, s) => const ReviewsScreen(),
      ),
      GoRoute(
        path: RouteNames.support,
        builder: (c, s) => const SupportScreen(),
      ),
      GoRoute(
        path: RouteNames.termsAndConditions,
        builder: (c, s) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (c, s) => const ProfileScreen(),
      ),
    ],
  );
}
