import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/localization/app_locale_scope.dart';
import 'core/localization/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_scope.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/lookups_cubit.dart';
import 'features/orders/presentation/bloc/active_order_cubit.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class DriverApp extends StatelessWidget {
  const DriverApp({
    super.key,
    required this.localeController,
    required this.themeController,
  });

  final LocaleController localeController;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<LookupsCubit>(create: (_) => sl<LookupsCubit>()),
        BlocProvider<ActiveOrderCubit>(create: (_) => sl<ActiveOrderCubit>()),
      ],
      child: AppLocaleScope(
        notifier: localeController,
        child: AppThemeScope(
          notifier: themeController,
          child: ListenableBuilder(
            listenable: Listenable.merge([localeController, themeController]),
            builder: (context, _) {
              final locale = localeController.locale;
              final code = locale.languageCode;
              return MaterialApp.router(
                title: 'Driver App',
                debugShowCheckedModeBanner: false,
                locale: locale,
                supportedLocales: const [Locale('ar'), Locale('en')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  ...AppLocalizations.localizationsDelegates,
                ],
                localeResolutionCallback: (deviceLocale, supportedLocales) {
                  if (code == 'ar' || code == 'en') return locale;
                  return const Locale('en');
                },
                theme: code == 'ar'
                    ? AppTheme.lightArabic
                    : AppTheme.lightEnglish,
                darkTheme: code == 'ar'
                    ? AppTheme.darkArabic
                    : AppTheme.darkEnglish,
                themeMode: themeController.themeMode,
                routerConfig: AppRouter.router,
              );
            },
          ),
        ),
      ),
    );
  }
}
