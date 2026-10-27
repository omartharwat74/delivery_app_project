import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  /// GET /wallet — fetch wallet balance and transaction items
  Future<Either<Failure, WalletEntity>> getWallet();

  /// POST /wallet/withdrawals — request balance withdrawal
  Future<Either<Failure, void>> requestWithdrawal(double amount);
}
