import 'package:equatable/equatable.dart';

import '../../domain/entities/wallet_entity.dart';

enum WalletStatus { initial, loading, loaded, error }

enum WithdrawalStatus { initial, loading, success, error }

class WalletState extends Equatable {
  final WalletStatus status;
  final WalletEntity? wallet;
  final String? errorMessage;
  final WithdrawalStatus withdrawalStatus;
  final String? withdrawalError;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.errorMessage,
    this.withdrawalStatus = WithdrawalStatus.initial,
    this.withdrawalError,
  });

  bool get isLoading => status == WalletStatus.loading;
  bool get isLoaded => status == WalletStatus.loaded && wallet != null;
  bool get hasError => status == WalletStatus.error;
  bool get isWithdrawing => withdrawalStatus == WithdrawalStatus.loading;

  WalletState copyWith({
    WalletStatus? status,
    WalletEntity? wallet,
    String? errorMessage,
    WithdrawalStatus? withdrawalStatus,
    String? withdrawalError,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      errorMessage: errorMessage,
      withdrawalStatus: withdrawalStatus ?? this.withdrawalStatus,
      withdrawalError: withdrawalError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    wallet,
    errorMessage,
    withdrawalStatus,
    withdrawalError,
  ];
}
