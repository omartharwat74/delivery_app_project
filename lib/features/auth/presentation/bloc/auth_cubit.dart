import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/network/auth_event_bus.dart';
import '../../data/models/driver_model.dart';
import '../../data/models/register_driver_request.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final AuthEventBus authEventBus;

  StreamSubscription<void>? _unauthorizedSubscription;
  String? _phoneNumber;
  String? _registrationToken;

  String? get phoneNumber => _phoneNumber;
  String? get registrationToken => _registrationToken;
  DriverModel? get currentDriver {
    final s = state;
    if (s is AuthAuthenticated) {
      return s.driver;
    }
    return null;
  }

  AuthCubit({
    required this.authRepository,
    required this.authEventBus,
  }) : super(AuthInitial()) {
    // Listen for global 401 Unauthorized events from Dio Interceptor
    _unauthorizedSubscription = authEventBus.onUnauthorized.listen((_) {
      _phoneNumber = null;
      _registrationToken = null;
      emit(AuthUnauthenticated());
    });
  }

  /// Normalizes Egyptian phone number to standard format (01xxxxxxxxx)
  String _normalizeEgyptPhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('20')) {
      digits = digits.substring(2);
    }
    if (!digits.startsWith('0') && digits.startsWith('1')) {
      digits = '0$digits';
    }
    return digits;
  }

  /// Checks the current authentication status on splash / startup
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final isLogged = await authRepository.isLoggedIn;
    if (!isLogged) {
      emit(AuthUnauthenticated());
      return;
    }

    final token = await authRepository.getAccessToken();
    if (token == null || token.isEmpty) {
      await authRepository.clearSession();
      emit(AuthUnauthenticated());
      return;
    }

    // Read cached driver profile if present
    final cachedDriver = await authRepository.getCachedDriver();

    // Verify session validity via GET /auth/me
    final meResult = await authRepository.getMe();
    await meResult.fold(
      (failure) async {
        // If 401 Unauthorized, token is expired or user was deleted from backend
        if (failure is UnauthorizedFailure || failure.statusCode == 401) {
          await authRepository.clearSession();
          _phoneNumber = null;
          _registrationToken = null;
          emit(AuthUnauthenticated());
        } else if (cachedDriver != null) {
          // If network / non-auth server error, allow offline session using cached profile
          emit(AuthAuthenticated(token: token, driver: cachedDriver));
        } else {
          // No cached profile and backend call failed
          await authRepository.clearSession();
          _phoneNumber = null;
          _registrationToken = null;
          emit(AuthUnauthenticated());
        }
      },
      (driver) async {
        emit(AuthAuthenticated(token: token, driver: driver));
      },
    );
  }

  /// Reloads driver profile from cache and/or remote API
  Future<void> loadDriverProfile() async {
    final token = await authRepository.getAccessToken();
    if (token == null || token.isEmpty) return;

    final cached = await authRepository.getCachedDriver();
    if (cached != null) {
      emit(AuthAuthenticated(token: token, driver: cached));
    }

    final meResult = await authRepository.getMe();
    await meResult.fold(
      (failure) async {
        if (failure is UnauthorizedFailure || failure.statusCode == 401) {
          await authRepository.clearSession();
          _phoneNumber = null;
          _registrationToken = null;
          emit(AuthUnauthenticated());
        }
      },
      (driver) async {
        emit(AuthAuthenticated(token: token, driver: driver));
      },
    );
  }

  /// Sets or updates the pending phone number
  void setPhoneNumber(String phone) {
    _phoneNumber = _normalizeEgyptPhone(phone);
  }

  /// Sends OTP to phone number (POST /auth/phone/send-otp)
  Future<void> submitPhone(String phone) async {
    final normalized = _normalizeEgyptPhone(phone);
    _phoneNumber = normalized;
    emit(AuthLoading());

    final result = await authRepository.sendOtp(normalized);
    result.fold(
      (failure) {
        emit(AuthError(failure.message, statusCode: failure.statusCode));
      },
      (response) {
        emit(AuthPhoneSubmitted(phone: normalized, debugOtp: response.debugOtp));
      },
    );
  }

  /// Resends OTP to phone number (POST /auth/phone/send-otp)
  Future<void> resendOtp({String? phone}) async {
    final target = phone != null && phone.isNotEmpty
        ? _normalizeEgyptPhone(phone)
        : _phoneNumber;
    if (target == null || target.isEmpty) {
      emit(AuthError(AppStrings.phoneRequired));
      return;
    }
    await submitPhone(target);
  }

  /// Verifies OTP (POST /auth/phone/verify-otp)
  /// Branches according to API status:
  /// - "authenticated": Save token & driver -> AuthAuthenticated
  /// - "complete_registration": Save registration_token -> AuthCompleteRegistration
  /// - 422 pending or 403 blocked -> AuthError with backend msg
  Future<void> verifyOtp(String otp) async {
    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      emit(AuthError(AppStrings.phoneRequired));
      return;
    }

    emit(AuthLoading());
    final result = await authRepository.verifyOtp(
      phone: _phoneNumber!,
      otp: otp.trim(),
    );

    result.fold(
      (failure) {
        emit(AuthError(failure.message, statusCode: failure.statusCode));
      },
      (data) {
        if (data.isAuthenticated) {
          emit(AuthAuthenticated(
            token: data.token ?? '',
            driver: data.delivery,
          ));
        } else if (data.isCompleteRegistration) {
          _registrationToken = data.registrationToken;
          emit(AuthCompleteRegistration(
            registrationToken: data.registrationToken ?? '',
            phone: _phoneNumber!,
          ));
        } else {
          emit(AuthError(AppStrings.unknownState));
        }
      },
    );
  }

  /// Completes driver registration with multipart/form-data (POST /auth/register)
  Future<void> submitRegistrationRequest(RegisterDriverRequest request) async {
    emit(AuthLoading());

    final result = await authRepository.registerDriver(request);
    result.fold(
      (failure) {
        emit(AuthError(failure.message, statusCode: failure.statusCode));
      },
      (response) {
        emit(AuthRegistrationPending(message: response.message));
        emit(AuthRegistrationSubmitted());
      },
    );
  }

  /// Registers driver with full API multipart request
  Future<void> registerDriver({
    required String name,
    required String phone,
    String? email,
    String? nationalId,
    required String vehicleType,
    required String areaId,
    required String shiftId,
    required File image,
    required File drivingLicense,
    required File vehicleLicense,
    required File nationalIdImage,
    required File vehicleFront,
    String? registrationToken,
  }) async {
    final regToken = registrationToken ??
        _registrationToken ??
        await authRepository.getRegistrationToken() ??
        '';

    final request = RegisterDriverRequest(
      registrationToken: regToken,
      name: name,
      phone: _normalizeEgyptPhone(phone),
      email: email,
      nationalId: nationalId,
      vehicleType: vehicleType,
      areaId: areaId,
      shiftId: shiftId,
      image: image,
      drivingLicense: drivingLicense,
      vehicleLicense: vehicleLicense,
      nationalIdImage: nationalIdImage,
      vehicleFront: vehicleFront,
    );

    await submitRegistrationRequest(request);
  }

  /// Legacy registration method for existing UI compatibility
  Future<void> submitRegistration({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String vehicleType,
    required String vehicleNumber,
    required String nationalId,
    required File? profilePhoto,
    required File? driverLicensePhoto,
    required File? vehicleLicensePhoto,
    required File? nationalIdPhoto,
    File? vehicleFrontPhoto,
    String? areaId,
    String? shiftId,
  }) async {
    emit(AuthLoading());

    final regToken = _registrationToken ??
        await authRepository.getRegistrationToken() ??
        '';

    if (profilePhoto == null ||
        driverLicensePhoto == null ||
        vehicleLicensePhoto == null ||
        nationalIdPhoto == null) {
      emit(AuthError(AppStrings.attachAllDocuments));
      return;
    }

    final fullName = '$firstName $lastName'.trim();
    final request = RegisterDriverRequest(
      registrationToken: regToken,
      name: fullName.isNotEmpty ? fullName : 'Driver',
      phone: _normalizeEgyptPhone(phone),
      email: email.isNotEmpty ? email : null,
      nationalId: nationalId.isNotEmpty ? nationalId : null,
      vehicleType: vehicleType,
      areaId: areaId ?? '1',
      shiftId: shiftId ?? '1',
      image: profilePhoto,
      drivingLicense: driverLicensePhoto,
      vehicleLicense: vehicleLicensePhoto,
      nationalIdImage: nationalIdPhoto,
      vehicleFront: vehicleFrontPhoto ?? vehicleLicensePhoto,
    );

    await submitRegistrationRequest(request);
  }

  /// Logs out driver (POST /auth/logout) and clears local session
  Future<void> logout() async {
    emit(AuthLogoutLoading());
    await authRepository.logout();
    _phoneNumber = null;
    _registrationToken = null;
    emit(AuthUnauthenticated());
  }

  /// Updates driver data in memory and notifies listeners
  void updateDriver(DriverModel updatedDriver) {
    final s = state;
    final token = s is AuthAuthenticated ? s.token : '';
    emit(AuthAuthenticated(token: token, driver: updatedDriver));
  }

  @override
  Future<void> close() {
    _unauthorizedSubscription?.cancel();
    return super.close();
  }
}
