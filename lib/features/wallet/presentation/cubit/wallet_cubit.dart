import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/entities/wallet_pending_withdrawal_entity.dart';
import '../../domain/entities/wallet_transaction_entity.dart';
import '../../domain/usecases/get_wallet_usecase.dart';
import '../../domain/usecases/request_withdrawal_usecase.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final GetWalletUseCase getWalletUseCase;
  final RequestWithdrawalUseCase requestWithdrawalUseCase;

  WalletCubit({
    required this.getWalletUseCase,
    required this.requestWithdrawalUseCase,
  }) : super(const WalletState());

  /// Fetch wallet and transactions. [silent] true avoids showing full-screen loading spinner.
  Future<void> fetchWallet({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(status: WalletStatus.loading, errorMessage: null));
    }

    final result = await getWalletUseCase(const NoParams());

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: WalletStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (wallet) {
        emit(
          state.copyWith(
            status: WalletStatus.loaded,
            wallet: wallet,
            errorMessage: null,
          ),
        );
      },
    );
  }

  /// Request withdrawal of specified amount.
  Future<bool> submitWithdrawal(double amount) async {
    emit(
      state.copyWith(
        withdrawalStatus: WithdrawalStatus.loading,
        withdrawalError: null,
      ),
    );

    final result = await requestWithdrawalUseCase(amount);

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            withdrawalStatus: WithdrawalStatus.error,
            withdrawalError: failure.message,
          ),
        );
        return false;
      },
      (_) async {
        if (state.wallet != null) {
          final current = state.wallet!;
          final newPending = WalletPendingWithdrawalEntity(
            id: DateTime.now().millisecondsSinceEpoch,
            amount: amount,
            status: 'pending',
            createdAt: DateTime.now().toIso8601String(),
          );
          final newPendingTx = WalletTransactionEntity(
            id: newPending.id,
            source: 'pending_withdrawal',
            amount: -amount.abs(),
            title: 'طلب سحب',
            status: 'pending',
            isPending: true,
            createdAt: newPending.createdAt,
          );

          final updatedTransactions = [
            newPendingTx,
            ...current.transactions.where((t) => t.source != 'pending_withdrawal'),
          ];

          final updatedWallet = WalletEntity(
            balance: current.balance - amount,
            maxDebt: current.maxDebt,
            debtRoom: current.debtRoom,
            pendingWithdrawal: newPending,
            transactions: updatedTransactions,
          );

          emit(
            state.copyWith(
              withdrawalStatus: WithdrawalStatus.success,
              wallet: updatedWallet,
              withdrawalError: null,
            ),
          );
        } else {
          emit(
            state.copyWith(
              withdrawalStatus: WithdrawalStatus.success,
              withdrawalError: null,
            ),
          );
        }

        // Silent refresh if available
        await fetchWallet(silent: true);
        return true;
      },
    );
  }

  void resetWithdrawalStatus() {
    emit(
      state.copyWith(
        withdrawalStatus: WithdrawalStatus.initial,
        withdrawalError: null,
      ),
    );
  }
}
