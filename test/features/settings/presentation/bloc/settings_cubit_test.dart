import 'package:dartz/dartz.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';
import 'package:delivery_app_project/features/settings/domain/repositories/settings_repository.dart';
import 'package:delivery_app_project/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSettingsRepository implements SettingsRepository {
  DriverModel? cachedDriver;
  bool shouldFail = false;
  String failureMessage = 'Error occurred';

  String currentOtpToken = 'fake_change_token_123';

  @override
  Future<DriverModel?> getCachedDriver() async => cachedDriver;

  @override
  Future<Either<Failure, DriverModel>> updateNotifications({
    required bool isNotify,
  }) async {
    if (shouldFail) return Left(ServerFailure(failureMessage));
    final updated = (cachedDriver ??
            const DriverModel(
              id: 1,
              name: 'Driver 1',
              phone: '01011112222',
            ))
        .copyWith(isNotify: isNotify);
    cachedDriver = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendCurrentOtp() async {
    if (shouldFail) return Left(ServerFailure(failureMessage));
    return const Right({'status': 'otp_sent', 'debug_otp': '123456'});
  }

  @override
  Future<Either<Failure, String>> verifyCurrentOtp({
    required String otp,
  }) async {
    if (shouldFail) return Left(ServerFailure(failureMessage));
    return Right(currentOtpToken);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendNewPhoneOtp({
    required String phoneChangeToken,
    required String newPhone,
  }) async {
    if (shouldFail) return Left(ServerFailure(failureMessage));
    return const Right({'status': 'otp_sent'});
  }

  @override
  Future<Either<Failure, DriverModel>> verifyNewPhoneOtp({
    required String phoneChangeToken,
    required String newPhone,
    required String otp,
  }) async {
    if (shouldFail) return Left(ServerFailure(failureMessage));
    final updated = (cachedDriver ??
            const DriverModel(
              id: 1,
              name: 'Driver 1',
              phone: '01011112222',
            ))
        .copyWith(phone: newPhone);
    cachedDriver = updated;
    return Right(updated);
  }
}

void main() {
  late FakeSettingsRepository fakeRepo;
  late SettingsCubit cubit;

  setUp(() {
    fakeRepo = FakeSettingsRepository();
    cubit = SettingsCubit(settingsRepository: fakeRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('SettingsCubit Tests', () {
    test('initSettings loads cached driver and notification status', () async {
      fakeRepo.cachedDriver = const DriverModel(
        id: 1,
        name: 'Ahmed',
        phone: '01012345678',
        isNotify: true,
      );

      await cubit.initSettings();

      expect(cubit.state.driver?.name, 'Ahmed');
      expect(cubit.state.currentPhone, '01012345678');
      expect(cubit.state.isNotify, true);
    });

    test('toggleNotifications updates state on success', () async {
      await cubit.toggleNotifications(false);

      expect(cubit.state.isNotify, false);
      expect(cubit.state.updateNotificationsSuccess, true);
      expect(cubit.state.errorMessage, isNull);
    });

    test('toggleNotifications emits error on failure', () async {
      fakeRepo.shouldFail = true;
      fakeRepo.failureMessage = 'Failed to update';

      await cubit.toggleNotifications(false);

      expect(cubit.state.updateNotificationsSuccess, false);
      expect(cubit.state.errorMessage, 'Failed to update');
    });

    test('Step 1: sendCurrentOtp sets sendCurrentOtpSuccess = true', () async {
      await cubit.sendCurrentOtp();

      expect(cubit.state.sendCurrentOtpSuccess, true);
      expect(cubit.state.errorMessage, isNull);
    });

    test('Step 2: verifyCurrentOtp stores phoneChangeToken and sets verifyCurrentOtpSuccess = true',
        () async {
      await cubit.verifyCurrentOtp('123456');

      expect(cubit.state.verifyCurrentOtpSuccess, true);
      expect(cubit.state.phoneChangeToken, 'fake_change_token_123');
      expect(cubit.state.errorMessage, isNull);
    });

    test('Step 3: sendNewPhoneOtp sets newPhone and sendNewOtpSuccess = true',
        () async {
      // First, establish phoneChangeToken
      await cubit.verifyCurrentOtp('123456');

      await cubit.sendNewPhoneOtp('01099998888');

      expect(cubit.state.sendNewOtpSuccess, true);
      expect(cubit.state.newPhone, '01099998888');
      expect(cubit.state.errorMessage, isNull);
    });

    test('Step 4: verifyNewPhoneOtp updates driver phone and sets changePhoneSuccess = true',
        () async {
      // Setup prerequisites
      await cubit.verifyCurrentOtp('123456');
      await cubit.sendNewPhoneOtp('01099998888');

      await cubit.verifyNewPhoneOtp('654321');

      expect(cubit.state.changePhoneSuccess, true);
      expect(cubit.state.driver?.phone, '01099998888');
      expect(cubit.state.errorMessage, isNull);
    });

    test('resetPhoneChangeFlow clears flow tokens and flags', () async {
      await cubit.verifyCurrentOtp('123456');
      await cubit.sendNewPhoneOtp('01099998888');

      cubit.resetPhoneChangeFlow();

      expect(cubit.state.phoneChangeToken, isNull);
      expect(cubit.state.sendCurrentOtpSuccess, false);
      expect(cubit.state.verifyCurrentOtpSuccess, false);
      expect(cubit.state.sendNewOtpSuccess, false);
      expect(cubit.state.changePhoneSuccess, false);
    });
  });
}
