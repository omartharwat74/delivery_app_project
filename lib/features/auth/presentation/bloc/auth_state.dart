import 'package:equatable/equatable.dart';

import '../../data/models/driver_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthPhoneSubmitted extends AuthState {
  final String phone;
  final String? debugOtp;

  const AuthPhoneSubmitted({
    required this.phone,
    this.debugOtp,
  });

  @override
  List<Object?> get props => [phone, debugOtp];
}

/// Emitted when data['status'] == "authenticated" (HTTP 200).
/// The driver is active and the Sanctum Bearer token is saved.
class AuthAuthenticated extends AuthState {
  final String token;
  final DriverModel? driver;

  const AuthAuthenticated({
    required this.token,
    this.driver,
  });

  @override
  List<Object?> get props => [token, driver];
}

/// Emitted when data['status'] == "complete_registration" (HTTP 200).
/// The phone is verified and the registration token is saved for registration.
class AuthCompleteRegistration extends AuthState {
  final String registrationToken;
  final String phone;

  const AuthCompleteRegistration({
    required this.registrationToken,
    required this.phone,
  });

  @override
  List<Object?> get props => [registrationToken, phone];
}

/// Emitted when POST /auth/register succeeds with status "pending_review" (HTTP 200).
class AuthRegistrationPending extends AuthState {
  final String message;

  const AuthRegistrationPending({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// Backward compatibility state for existing UI components
class AuthRegistrationSubmitted extends AuthState {}

/// Backward compatibility state for existing OTP listeners
class AuthOtpVerified extends AuthState {
  final bool isNewDriver;
  final String? registrationToken;

  const AuthOtpVerified({
    required this.isNewDriver,
    this.registrationToken,
  });

  @override
  List<Object?> get props => [isNewDriver, registrationToken];
}

class AuthUnauthenticated extends AuthState {}

class AuthLogoutLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? validationErrors;

  const AuthError(
    this.message, {
    this.statusCode,
    this.validationErrors,
  });

  @override
  List<Object?> get props => [message, statusCode, validationErrors];
}
