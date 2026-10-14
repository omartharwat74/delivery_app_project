import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/core/network/auth_event_bus.dart';
import 'package:delivery_app_project/features/auth/data/models/area_model.dart';
import 'package:delivery_app_project/features/auth/data/models/shift_model.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';
import 'package:delivery_app_project/features/auth/data/models/register_driver_request.dart';
import 'package:delivery_app_project/features/auth/data/models/register_driver_response.dart';
import 'package:delivery_app_project/features/auth/data/models/send_otp_response.dart';
import 'package:delivery_app_project/features/auth/data/models/verify_otp_response.dart';
import 'package:delivery_app_project/features/auth/data/models/auth_response.dart';
import 'package:delivery_app_project/features/auth/domain/entities/driver_registration.dart';
import 'package:delivery_app_project/features/auth/domain/entities/driver_session.dart';
import 'package:delivery_app_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:delivery_app_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:delivery_app_project/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository implements AuthRepository {
  bool loggedInValue = false;
  String? tokenValue;
  String? registrationTokenValue;
  DriverModel? cachedDriverValue;

  Either<Failure, SendOtpResponse>? sendOtpResult;
  Either<Failure, VerifyOtpResponse>? verifyOtpResult;
  Either<Failure, RegisterDriverResponse>? registerDriverResult;
  Either<Failure, void>? logoutResult;
  Either<Failure, List<AreaModel>>? getAreasResult;
  Either<Failure, List<ShiftModel>>? getShiftsResult;
  Either<Failure, DriverModel>? getMeResult;

  @override
  Future<Either<Failure, List<AreaModel>>> getAreas() async {
    return getAreasResult ?? const Right([AreaModel(id: 1, name: 'القاهرة')]);
  }

  @override
  Future<Either<Failure, List<ShiftModel>>> getShifts() async {
    return getShiftsResult ??
        const Right([
          ShiftModel(
            id: 1,
            name: 'صباحي',
            startsAt: '08:00',
            endsAt: '16:00',
          )
        ]);
  }

  @override
  Future<bool> get isLoggedIn async => loggedInValue;

  @override
  Future<String?> getAccessToken() async => tokenValue;

  @override
  Future<String?> getRegistrationToken() async => registrationTokenValue;

  @override
  Future<void> saveRegistrationToken(String token) async {
    registrationTokenValue = token;
  }

  @override
  Future<DriverModel?> getCachedDriver() async => cachedDriverValue;

  @override
  Future<Either<Failure, void>> clearSession() async {
    tokenValue = null;
    registrationTokenValue = null;
    cachedDriverValue = null;
    loggedInValue = false;
    return const Right(null);
  }

  @override
  Future<Either<Failure, SendOtpResponse>> sendOtp(String phone) async {
    return sendOtpResult ?? const Right(SendOtpResponse(status: 'otp_sent'));
  }

  @override
  Future<Either<Failure, VerifyOtpResponse>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return verifyOtpResult ??
        const Right(
          VerifyOtpResponse(
            status: 'authenticated',
            token: 'test_token',
          ),
        );
  }

  @override
  Future<Either<Failure, RegisterDriverResponse>> registerDriver(
    RegisterDriverRequest request,
  ) async {
    return registerDriverResult ??
        const Right(
          RegisterDriverResponse(
            status: 'pending_review',
            message: 'تم إرسال طلبك وهو قيد مراجعة الإدارة.',
          ),
        );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (logoutResult != null && logoutResult!.isLeft()) {
      return logoutResult!;
    }
    await clearSession();
    return logoutResult ?? const Right(null);
  }

  @override
  Future<Either<Failure, DriverModel>> getMe() async {
    return getMeResult ??
        Right(cachedDriverValue ?? const DriverModel(id: 1, name: 'Driver', phone: '01011112222'));
  }

  @override
  Future<Either<Failure, void>> sendDriverLoginOtp(String phone) => sendOtp(phone);

  @override
  Future<Either<Failure, AuthResponse>> verifyDriverLoginOtp(String phone, String otp) async {
    return const Right(AuthResponse(
      accessToken: 'token',
      refreshToken: '',
      tokenType: 'Bearer',
      userId: '1',
      phone: '01011112222',
      firstName: 'Driver',
      lastName: '',
      fullName: 'Driver',
      role: 'driver',
      newUser: false,
    ));
  }

  @override
  Future<Either<Failure, DriverRegistration>> registerDriverLegacy(RegisterDriverParams params) async {
    return const Right(DriverRegistration(userId: '1', message: 'Success'));
  }

  @override
  Future<String?> uploadMedia(String filePath) async => 'http://example.com/image.jpg';

  @override
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken) async {
    return const Right(AuthResponse(
      accessToken: 'refreshed',
      refreshToken: '',
      tokenType: 'Bearer',
      userId: '1',
      phone: '01011112222',
      firstName: 'Driver',
      lastName: '',
      fullName: 'Driver',
      role: 'driver',
      newUser: false,
    ));
  }

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<Either<Failure, DriverSession?>> getCachedSession() async => const Right(null);
}

void main() {
  late MockAuthRepository mockRepository;
  late AuthEventBus authEventBus;
  late AuthCubit cubit;

  setUp(() {
    mockRepository = MockAuthRepository();
    authEventBus = AuthEventBus();
    authEventBus.reset();
    cubit = AuthCubit(
      authRepository: mockRepository,
      authEventBus: authEventBus,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('Auth Flow State Machine Tests', () {
    test('submitPhone emits [AuthLoading, AuthPhoneSubmitted] on success', () async {
      mockRepository.sendOtpResult = const Right(
        SendOtpResponse(status: 'otp_sent', debugOtp: '123456'),
      );

      final expectedStates = [
        AuthLoading(),
        const AuthPhoneSubmitted(phone: '01011112222', debugOtp: '123456'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.submitPhone('01011112222');
      expect(cubit.phoneNumber, '01011112222');
    });

    test('submitPhone normalizes +20 format to Egypt 01xxxxxxxxx', () async {
      mockRepository.sendOtpResult = const Right(
        SendOtpResponse(status: 'otp_sent'),
      );

      await cubit.submitPhone('+201011112222');
      expect(cubit.phoneNumber, '01011112222');
    });

    test('verifyOtp branches to AuthAuthenticated when status == "authenticated"', () async {
      await cubit.submitPhone('01011112222');

      const driver = DriverModel(id: 1, name: 'Driver One', phone: '01011112222');
      mockRepository.verifyOtpResult = const Right(
        VerifyOtpResponse(
          status: 'authenticated',
          token: 'sanctum_token_123',
          delivery: driver,
        ),
      );

      final expectedStates = [
        AuthLoading(),
        const AuthAuthenticated(token: 'sanctum_token_123', driver: driver),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.verifyOtp('123456');
    });

    test('verifyOtp branches to AuthCompleteRegistration when status == "complete_registration"', () async {
      await cubit.submitPhone('01011112222');

      mockRepository.verifyOtpResult = const Right(
        VerifyOtpResponse(
          status: 'complete_registration',
          registrationToken: 'reg_token_456',
        ),
      );

      final expectedStates = [
        AuthLoading(),
        const AuthCompleteRegistration(
          registrationToken: 'reg_token_456',
          phone: '01011112222',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.verifyOtp('123456');
      expect(cubit.registrationToken, 'reg_token_456');
    });

    test('verifyOtp emits AuthError on 422 pending review message', () async {
      await cubit.submitPhone('01011112222');

      mockRepository.verifyOtpResult = const Left(
        ValidationFailure('طلبك قيد المراجعة. لا يمكنك الدخول حتى تتم الموافقة.'),
      );

      final expectedStates = [
        AuthLoading(),
        const AuthError('طلبك قيد المراجعة. لا يمكنك الدخول حتى تتم الموافقة.', statusCode: 422),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.verifyOtp('123456');
    });

    test('verifyOtp emits AuthError on 403 blocked message', () async {
      await cubit.submitPhone('01011112222');

      mockRepository.verifyOtpResult = const Left(
        ForbiddenFailure('تم حظر الحساب'),
      );

      final expectedStates = [
        AuthLoading(),
        const AuthError('تم حظر الحساب', statusCode: 403),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.verifyOtp('123456');
    });

    test('AuthEventBus triggers AuthUnauthenticated on 401 Unauthorized event', () async {
      authEventBus.emitUnauthorized();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state, isA<AuthUnauthenticated>());
    });

    test('logout emits [AuthLogoutLoading, AuthUnauthenticated] and clears currentDriver', () async {
      final expectedStates = [
        AuthLogoutLoading(),
        AuthUnauthenticated(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.logout();
      expect(cubit.currentDriver, isNull);
    });

    test('logout retains token/session and emits [AuthLogoutLoading, AuthError, AuthAuthenticated] when 422 busy error occurs', () async {
      mockRepository.loggedInValue = true;
      mockRepository.tokenValue = 'active_delivery_token';
      const driver = DriverModel(
        id: 1,
        name: 'Captain Delivery',
        phone: '01011112222',
        isOnline: true,
        isBusy: true,
      );
      mockRepository.cachedDriverValue = driver;

      // Put cubit in authenticated state
      cubit.updateDriver(driver);

      mockRepository.logoutResult = const Left(
        ValidationFailure('لا يمكنك إنهاء الشيفت أو تسجيل الخروج أثناء تنفيذ طلب.', errors: {}),
      );

      final expectedStates = [
        AuthLogoutLoading(),
        const AuthError('لا يمكنك إنهاء الشيفت أو تسجيل الخروج أثناء تنفيذ طلب.', statusCode: 422),
        const AuthAuthenticated(token: 'active_delivery_token', driver: driver),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.logout();

      // Ensure session is NOT cleared and driver is still active
      expect(mockRepository.tokenValue, 'active_delivery_token');
      expect(cubit.state, isA<AuthAuthenticated>());
      expect(cubit.currentDriver?.isBusy, isTrue);
    });

    test('checkAuthStatus emits AuthUnauthenticated when not logged in', () async {
      mockRepository.loggedInValue = false;
      mockRepository.tokenValue = null;

      await cubit.checkAuthStatus();
      expect(cubit.state, isA<AuthUnauthenticated>());
    });

    test('checkAuthStatus emits AuthAuthenticated with cached driver', () async {
      mockRepository.loggedInValue = true;
      mockRepository.tokenValue = 'saved_token_123';
      const driver = DriverModel(id: 42, name: 'Omar Tharwat', phone: '01064178619');
      mockRepository.cachedDriverValue = driver;

      await cubit.checkAuthStatus();
      expect(cubit.state, isA<AuthAuthenticated>());
      final authState = cubit.state as AuthAuthenticated;
      expect(authState.token, 'saved_token_123');
      expect(authState.driver?.name, 'Omar Tharwat');
      expect(cubit.currentDriver?.name, 'Omar Tharwat');
    });

    test('loadDriverProfile updates currentDriver from cache', () async {
      mockRepository.loggedInValue = true;
      mockRepository.tokenValue = 'active_token';
      const driver = DriverModel(id: 7, name: 'Delivery Captain', phone: '01099998888');
      mockRepository.cachedDriverValue = driver;

      await cubit.loadDriverProfile();
      expect(cubit.currentDriver?.name, 'Delivery Captain');
    });

    test('checkAuthStatus emits AuthUnauthenticated and clears session when getMe returns 401 Unauthorized', () async {
      mockRepository.loggedInValue = true;
      mockRepository.tokenValue = 'invalid_expired_token';
      mockRepository.cachedDriverValue = const DriverModel(id: 1, name: 'Deleted Driver', phone: '01011112222');
      mockRepository.getMeResult = const Left(UnauthorizedFailure('Unauthenticated'));

      await cubit.checkAuthStatus();

      expect(cubit.state, isA<AuthUnauthenticated>());
      expect(cubit.currentDriver, isNull);
      expect(mockRepository.tokenValue, isNull);
    });

    test('checkAuthStatus emits AuthAuthenticated with cached driver when getMe returns NetworkFailure', () async {
      mockRepository.loggedInValue = true;
      mockRepository.tokenValue = 'valid_token';
      mockRepository.cachedDriverValue = const DriverModel(id: 99, name: 'Offline Driver', phone: '01055554444');
      mockRepository.getMeResult = const Left(NetworkFailure('No Internet'));

      await cubit.checkAuthStatus();

      expect(cubit.state, isA<AuthAuthenticated>());
      final authState = cubit.state as AuthAuthenticated;
      expect(authState.token, 'valid_token');
      expect(authState.driver?.name, 'Offline Driver');
    });

    test('checkAuthStatus emits AuthUnauthenticated when getMe returns NetworkFailure and no cached driver', () async {
      mockRepository.loggedInValue = true;
      mockRepository.tokenValue = 'valid_token';
      mockRepository.cachedDriverValue = null;
      mockRepository.getMeResult = const Left(NetworkFailure('No Internet'));

      await cubit.checkAuthStatus();

      expect(cubit.state, isA<AuthUnauthenticated>());
      expect(mockRepository.tokenValue, isNull);
    });

    test('loadDriverProfile emits AuthUnauthenticated when getMe returns 401 Unauthorized', () async {
      mockRepository.loggedInValue = true;
      mockRepository.tokenValue = 'expired_token';
      mockRepository.cachedDriverValue = const DriverModel(id: 2, name: 'Driver', phone: '010');
      mockRepository.getMeResult = const Left(UnauthorizedFailure('Unauthenticated'));

      await cubit.loadDriverProfile();

      expect(cubit.state, isA<AuthUnauthenticated>());
      expect(cubit.currentDriver, isNull);
    });
  });
}
