import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository settingsRepository;
  final AuthCubit? authCubit;

  SettingsCubit({
    required this.settingsRepository,
    this.authCubit,
  }) : super(const SettingsState());

  /// Loads cached driver and initializes notification status
  Future<void> initSettings() async {
    final driver = await settingsRepository.getCachedDriver();
    emit(state.copyWith(
      driver: driver,
      isNotify: driver?.isNotify ?? true,
      currentPhone: driver?.phone,
    ));
  }

  /// Toggles push notifications on/off via PUT /profile/notifications
  Future<void> toggleNotifications(bool value) async {
    emit(state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      updateNotificationsSuccess: false,
    ));

    final result = await settingsRepository.updateNotifications(isNotify: value);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          updateNotificationsSuccess: false,
        ));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!isClosed) {
            emit(state.copyWith(clearErrorMessage: true));
          }
        });
      },
      (updatedDriver) {
        authCubit?.updateDriver(updatedDriver);
        emit(state.copyWith(
          isLoading: false,
          isNotify: updatedDriver.isNotify,
          driver: updatedDriver,
          updateNotificationsSuccess: true,
          clearErrorMessage: true,
        ));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!isClosed) {
            emit(state.copyWith(updateNotificationsSuccess: false));
          }
        });
      },
    );
  }

  /// Explicitly resets transient action status (success/error flags)
  void resetActionStatus() {
    emit(state.copyWith(
      updateNotificationsSuccess: false,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    ));
  }

  /// Step 1: Request OTP for driver's current registered phone (POST /profile/phone/send-current-otp)
  Future<void> sendCurrentOtp() async {
    emit(state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      sendCurrentOtpSuccess: false,
    ));

    final result = await settingsRepository.sendCurrentOtp();

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          sendCurrentOtpSuccess: false,
        ));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!isClosed) {
            emit(state.copyWith(clearErrorMessage: true));
          }
        });
      },
      (_) {
        emit(state.copyWith(
          isLoading: false,
          sendCurrentOtpSuccess: true,
          clearErrorMessage: true,
        ));
      },
    );
  }

  /// Step 2: Verify OTP for current phone (POST /profile/phone/verify-current-otp)
  /// Saves the returned phone_change_token in state
  Future<void> verifyCurrentOtp(String otp) async {
    emit(state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      verifyCurrentOtpSuccess: false,
    ));

    final result = await settingsRepository.verifyCurrentOtp(otp: otp);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          verifyCurrentOtpSuccess: false,
        ));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!isClosed) {
            emit(state.copyWith(clearErrorMessage: true));
          }
        });
      },
      (token) {
        emit(state.copyWith(
          isLoading: false,
          phoneChangeToken: token,
          verifyCurrentOtpSuccess: true,
          clearErrorMessage: true,
        ));
      },
    );
  }

  /// Step 3: Send OTP to the new phone number (POST /profile/phone/send-otp)
  Future<void> sendNewPhoneOtp(String newPhone) async {
    final token = state.phoneChangeToken;
    if (token == null || token.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'رمز تغيير الجوال غير صالح أو منتهي، يرجى إعادة المحاولة',
      ));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) {
          emit(state.copyWith(clearErrorMessage: true));
        }
      });
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      sendNewOtpSuccess: false,
    ));

    final result = await settingsRepository.sendNewPhoneOtp(
      phoneChangeToken: token,
      newPhone: newPhone,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          sendNewOtpSuccess: false,
        ));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!isClosed) {
            emit(state.copyWith(clearErrorMessage: true));
          }
        });
      },
      (_) {
        emit(state.copyWith(
          isLoading: false,
          newPhone: newPhone,
          sendNewOtpSuccess: true,
          clearErrorMessage: true,
        ));
      },
    );
  }

  /// Step 4: Verify new phone OTP (POST /profile/phone/verify-otp)
  /// On success: updates driver local cache, updates AuthCubit, emits changePhoneSuccess
  Future<void> verifyNewPhoneOtp(String otp) async {
    final token = state.phoneChangeToken;
    final newPhone = state.newPhone;
    if (token == null || token.isEmpty || newPhone == null || newPhone.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'بيانات التحقق غير مكتملة، يرجى إعادة المحاولة',
      ));
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) {
          emit(state.copyWith(clearErrorMessage: true));
        }
      });
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      changePhoneSuccess: false,
    ));

    final result = await settingsRepository.verifyNewPhoneOtp(
      phoneChangeToken: token,
      newPhone: newPhone,
      otp: otp,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          changePhoneSuccess: false,
        ));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!isClosed) {
            emit(state.copyWith(clearErrorMessage: true));
          }
        });
      },
      (updatedDriver) {
        authCubit?.updateDriver(updatedDriver);
        emit(state.copyWith(
          isLoading: false,
          driver: updatedDriver,
          currentPhone: updatedDriver.phone,
          changePhoneSuccess: true,
          clearErrorMessage: true,
        ));
      },
    );
  }

  /// Resets temporary state after phone change flow completes or is cancelled
  void resetPhoneChangeFlow() {
    emit(state.copyWith(
      clearPhoneChangeToken: true,
      sendCurrentOtpSuccess: false,
      verifyCurrentOtpSuccess: false,
      sendNewOtpSuccess: false,
      changePhoneSuccess: false,
      clearErrorMessage: true,
    ));
  }

  /// Fetches general settings including terms and conditions (GET /general-settings)
  Future<void> loadTerms() async {
    emit(state.copyWith(
      isTermsLoading: true,
      clearTermsErrorMessage: true,
    ));

    final result = await settingsRepository.getGeneralSettings();

    result.fold(
      (failure) {
        emit(state.copyWith(
          isTermsLoading: false,
          termsErrorMessage: failure.message,
        ));
      },
      (generalSettings) {
        emit(state.copyWith(
          isTermsLoading: false,
          terms: generalSettings.terms,
          clearTermsErrorMessage: true,
        ));
      },
    );
  }
}
