import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/core/network/auth_event_bus.dart';
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
    await clearSession();
    return logoutResult ?? const Right(null);
  }

  @override
  Future<Either<Failure, DriverModel>> getMe() async {
    return Right(cachedDriverValue ?? const DriverModel(id: 1, name: 'Driver', phone: '01011112222'));
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

    test('logout emits [AuthLogoutLoading, AuthUnauthenticated]', () async {
      final expectedStates = [
        AuthLogoutLoading(),
        AuthUnauthenticated(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.logout();
    });
  });
}
