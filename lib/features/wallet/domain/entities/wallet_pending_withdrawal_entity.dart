import 'package:equatable/equatable.dart';

class WalletPendingWithdrawalEntity extends Equatable {
  final dynamic id;
  final double amount;
  final String status;
  final String? createdAt;

  const WalletPendingWithdrawalEntity({
    required this.id,
    required this.amount,
    required this.status,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, amount, status, createdAt];
}
