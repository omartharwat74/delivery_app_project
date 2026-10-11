import 'package:equatable/equatable.dart';

import '../../../auth/data/models/driver_model.dart';

class SettingsState extends Equatable {
  final bool isNotify;
  final DriverModel? driver;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool updateNotificationsSuccess;

  // Change phone flow
  final String? phoneChangeToken;
  final String? currentPhone;
  final String? newPhone;
  final bool sendCurrentOtpSuccess;
  final bool verifyCurrentOtpSuccess;
  final bool sendNewOtpSuccess;
  final bool changePhoneSuccess;

  // General settings (Terms & conditions)
  final String? terms;
  final bool isTermsLoading;
  final String? termsErrorMessage;

  const SettingsState({
    this.isNotify = true,
    this.driver,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.updateNotificationsSuccess = false,
    this.phoneChangeToken,
    this.currentPhone,
    this.newPhone,
    this.sendCurrentOtpSuccess = false,
    this.verifyCurrentOtpSuccess = false,
    this.sendNewOtpSuccess = false,
    this.changePhoneSuccess = false,
    this.terms,
    this.isTermsLoading = false,
    this.termsErrorMessage,
  });

  SettingsState copyWith({
    bool? isNotify,
    DriverModel? driver,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    bool? updateNotificationsSuccess,
    String? phoneChangeToken,
    bool clearPhoneChangeToken = false,
    String? currentPhone,
    String? newPhone,
    bool? sendCurrentOtpSuccess,
    bool? verifyCurrentOtpSuccess,
    bool? sendNewOtpSuccess,
    bool? changePhoneSuccess,
    String? terms,
    bool? isTermsLoading,
    String? termsErrorMessage,
    bool clearTermsErrorMessage = false,
  }) {
    return SettingsState(
      isNotify: isNotify ?? this.isNotify,
      driver: driver ?? this.driver,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      updateNotificationsSuccess:
          updateNotificationsSuccess ?? this.updateNotificationsSuccess,
      phoneChangeToken: clearPhoneChangeToken
          ? null
          : (phoneChangeToken ?? this.phoneChangeToken),
      currentPhone: currentPhone ?? this.currentPhone,
      newPhone: newPhone ?? this.newPhone,
      sendCurrentOtpSuccess:
          sendCurrentOtpSuccess ?? this.sendCurrentOtpSuccess,
      verifyCurrentOtpSuccess:
          verifyCurrentOtpSuccess ?? this.verifyCurrentOtpSuccess,
      sendNewOtpSuccess: sendNewOtpSuccess ?? this.sendNewOtpSuccess,
      changePhoneSuccess: changePhoneSuccess ?? this.changePhoneSuccess,
      terms: terms ?? this.terms,
      isTermsLoading: isTermsLoading ?? this.isTermsLoading,
      termsErrorMessage: clearTermsErrorMessage
          ? null
          : (termsErrorMessage ?? this.termsErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isNotify,
    driver,
    isLoading,
    errorMessage,
    successMessage,
    updateNotificationsSuccess,
    phoneChangeToken,
    currentPhone,
    newPhone,
    sendCurrentOtpSuccess,
    verifyCurrentOtpSuccess,
    sendNewOtpSuccess,
    changePhoneSuccess,
    terms,
    isTermsLoading,
    termsErrorMessage,
  ];
}
