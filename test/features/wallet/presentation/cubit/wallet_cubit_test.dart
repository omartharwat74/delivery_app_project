import 'package:dartz/dartz.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/wallet/domain/entities/wallet_entity.dart';
import 'package:delivery_app_project/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:delivery_app_project/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:delivery_app_project/features/wallet/domain/usecases/request_withdrawal_usecase.dart';
import 'package:delivery_app_project/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:delivery_app_project/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWalletRepository implements WalletRepository {
  WalletEntity? mockWallet;
  bool shouldFailGet = false;
  bool shouldFailWithdraw = false;
  String failureMsg = 'Error occurred';

  @override
  Future<Either<Failure, WalletEntity>> getWallet() async {
    if (shouldFailGet) return Left(ServerFailure(failureMsg));
    return Right(
      mockWallet ??
          const WalletEntity(
            balance: 1000.0,
            maxDebt: 500.0,
            debtRoom: 500.0,
            transactions: [],
          ),
    );
  }

  @override
  Future<Either<Failure, void>> requestWithdrawal(double amount) async {
    if (shouldFailWithdraw) return Left(ServerFailure(failureMsg));
    return const Right(null);
  }
}

void main() {
  late FakeWalletRepository fakeRepo;
  late GetWalletUseCase getWalletUseCase;
  late RequestWithdrawalUseCase requestWithdrawalUseCase;
  late WalletCubit cubit;

  setUp(() {
    fakeRepo = FakeWalletRepository();
    getWalletUseCase = GetWalletUseCase(fakeRepo);
    requestWithdrawalUseCase = RequestWithdrawalUseCase(fakeRepo);
    cubit = WalletCubit(
      getWalletUseCase: getWalletUseCase,
      requestWithdrawalUseCase: requestWithdrawalUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('WalletCubit', () {
    test('initial state is WalletState()', () {
      expect(cubit.state, const WalletState());
      expect(cubit.state.status, WalletStatus.initial);
    });

    test('fetchWallet emits [loading, loaded] on success', () async {
      const entity = WalletEntity(
        balance: 1350.0,
        maxDebt: 500.0,
        debtRoom: 380.0,
        transactions: [],
      );
      fakeRepo.mockWallet = entity;

      final expectedStates = [
        const WalletState(status: WalletStatus.loading),
        const WalletState(status: WalletStatus.loaded, wallet: entity),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.fetchWallet();
    });

    test('fetchWallet emits [loading, error] on failure', () async {
      fakeRepo.shouldFailGet = true;
      fakeRepo.failureMsg = 'Failed to load wallet';

      final expectedStates = [
        const WalletState(status: WalletStatus.loading),
        const WalletState(
          status: WalletStatus.error,
          errorMessage: 'Failed to load wallet',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.fetchWallet();
    });

    test('submitWithdrawal returns true and reloads wallet silently on success', () async {
      final success = await cubit.submitWithdrawal(250.0);

      expect(success, isTrue);
      expect(cubit.state.withdrawalStatus, WithdrawalStatus.success);
      expect(cubit.state.status, WalletStatus.loaded);
    });

    test('submitWithdrawal returns false on failure', () async {
      fakeRepo.shouldFailWithdraw = true;
      fakeRepo.failureMsg = 'Insufficient balance';

      final success = await cubit.submitWithdrawal(5000.0);

      expect(success, isFalse);
      expect(cubit.state.withdrawalStatus, WithdrawalStatus.error);
      expect(cubit.state.withdrawalError, 'Insufficient balance');
    });
  });
}
