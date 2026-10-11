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
import '../../features/profile/presentation/bloc/chat_cubit.dart';
import '../../features/profile/presentation/bloc/phone_change/phone_change_cubit.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/orders/presentation/bloc/active_order_cubit.dart';
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
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../network/api_client.dart';
import '../network/auth_event_bus.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init({required SharedPreferences prefs}) async {
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  sl.registerLazySingleton<AuthEventBus>(() => AuthEventBus());

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

  sl.registerLazySingleton(() => CheckAuthSessionUseCase(sl()));
  sl.registerLazySingleton(() => RegisterDriverUseCase(sl()));
  sl.registerLazySingleton(() => UploadMediaUseCase(sl()));
  sl.registerLazySingleton(() => SendDriverLoginOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyDriverLoginOtpUseCase(sl()));

  sl.registerFactory(
    () => AuthCubit(
      authRepository: sl(),
      authEventBus: sl(),
    ),
  );

  sl.registerFactory(() => LookupsCubit(authRepository: sl()));

  sl.registerFactory(
    () => HomeCubit(
      homeRepository: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerFactory(() => ChatCubit());
  sl.registerFactory(() => ProfileBloc());
  sl.registerFactory(() => PhoneChangeCubit());

  sl.registerLazySingleton(() => ActiveOrderCubit());
}
