import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';

class RequestWithdrawalUseCase implements UseCase<void, double> {
  final WalletRepository repository;

  RequestWithdrawalUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(double amount) {
    return repository.requestWithdrawal(amount);
  }
}
