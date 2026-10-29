import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_session_usecase.dart';
import '../../features/auth/domain/usecases/register_driver_usecase.dart';
import '../../features/auth/domain/usecases/send_driver_login_otp_usecase.dart';
import '../../features/auth/domain/usecases/upload_media_usecase.dart';
import '../../features/auth/domain/usecases/verify_driver_login_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/lookups_cubit.dart';
import '../../features/profile/presentation/bloc/phone_change/phone_change_cubit.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/support/presentation/cubit/support_cubit.dart';
import '../../features/orders/presentation/bloc/active_order_cubit.dart';
import '../../features/orders/presentation/bloc/orders_cubit.dart';
import '../../features/earnings/data/datasources/earnings_local_datasource.dart';
import '../../features/earnings/data/datasources/earnings_remote_datasource.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../../features/navigation_map/data/datasources/map_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/orders/data/datasources/order_local_datasource.dart';
import '../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/reviews/data/datasources/reviews_remote_datasource.dart';
import '../../features/reviews/data/repositories/reviews_repository_impl.dart';
import '../../features/reviews/domain/repositories/reviews_repository.dart';
import '../../features/reviews/presentation/bloc/reviews_cubit.dart';
import '../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';
import '../network/api_client.dart';
import '../localization/locale_controller.dart';
import '../network/auth_event_bus.dart';
import '../network/network_info.dart';
import '../router/app_router.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../../features/working_hours/data/datasources/working_hours_remote_datasource.dart';
import '../../features/working_hours/data/repositories/working_hours_repository_impl.dart';
import '../../features/working_hours/domain/repositories/working_hours_repository.dart';
import '../../features/working_hours/domain/usecases/add_working_hours_usecase.dart';
import '../../features/working_hours/domain/usecases/delete_working_hours_usecase.dart';
import '../../features/working_hours/domain/usecases/get_working_hours_usecase.dart';
import '../../features/working_hours/domain/usecases/update_working_hours_usecase.dart';
import '../../features/working_hours/presentation/cubit/working_hours_cubit.dart';
import '../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/get_wallet_usecase.dart';
import '../../features/wallet/domain/usecases/request_withdrawal_usecase.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';

final sl = GetIt.instance;

Future<void> init({required SharedPreferences prefs}) async {
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<LocaleController>(
    () => LocaleController(sl<SharedPreferences>())..hydrate(),
  );

  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  sl.registerLazySingleton<AuthEventBus>(() => AuthEventBus());
  AppRouter.listenToAuthEvents(eventBus: sl<AuthEventBus>());

  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton(() => Connectivity());

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl(), sharedPreferences: sl()),
  );

  sl.registerLazySingleton(
    () => ApiClient(
      dio: sl(),
      localDataSource: sl(),
      sharedPreferences: sl(),
      authEventBus: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OrderLocalDataSource>(
    () => OrderLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<EarningsRemoteDataSource>(
    () => EarningsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<EarningsLocalDataSource>(
    () => EarningsLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<MapRemoteDataSource>(
    () => MapRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      authLocalDataSource: sl(),
      homeLocalDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => CheckAuthSessionUseCase(sl()));
  sl.registerLazySingleton(() => RegisterDriverUseCase(sl()));
  sl.registerLazySingleton(() => UploadMediaUseCase(sl()));
  sl.registerLazySingleton(() => SendDriverLoginOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyDriverLoginOtpUseCase(sl()));

  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      remoteDataSource: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // Notifications
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(() => NotificationsCubit(repository: sl()));

  // Reviews
  sl.registerLazySingleton<ReviewsRemoteDataSource>(
    () => ReviewsRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(() => ReviewsCubit(repository: sl()));

  // Working Hours
  sl.registerLazySingleton<WorkingHoursRemoteDataSource>(
    () => WorkingHoursRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<WorkingHoursRepository>(
    () => WorkingHoursRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetWorkingHoursUseCase(sl()));
  sl.registerLazySingleton(() => AddWorkingHoursUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWorkingHoursUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWorkingHoursUseCase(sl()));
  sl.registerFactory(
    () => WorkingHoursCubit(
      getWorkingHoursUseCase: sl(),
      addWorkingHoursUseCase: sl(),
      deleteWorkingHoursUseCase: sl(),
      updateWorkingHoursUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => AuthCubit(
      authRepository: sl(),
      authEventBus: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => SettingsCubit(
      settingsRepository: sl(),
      authCubit: sl<AuthCubit>(),
    ),
  );

  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  sl.registerLazySingleton<NotificationService>(() => NotificationServiceImpl());

  sl.registerFactory(() => LookupsCubit(authRepository: sl()));

  sl.registerFactory(
    () => HomeCubit(
      homeRepository: sl(),
      sharedPreferences: sl(),
      locationService: sl(),
      notificationService: sl(),
      authEventBus: sl(),
    ),
  );

  sl.registerFactory(() => SupportCubit(dio: sl<ApiClient>().dio));
  sl.registerFactory(() => ProfileBloc());
  sl.registerFactory(() => PhoneChangeCubit());

  // Wallet
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetWalletUseCase(sl()));
  sl.registerLazySingleton(() => RequestWithdrawalUseCase(sl()));
  sl.registerFactory(
    () => WalletCubit(
      getWalletUseCase: sl(),
      requestWithdrawalUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ActiveOrderCubit(
      orderRepository: sl(),
      localeController: sl.isRegistered<LocaleController>()
          ? sl<LocaleController>()
          : null,
    ),
  );
  sl.registerFactory(
    () => OrdersCubit(orderRepository: sl()),
  );
}
