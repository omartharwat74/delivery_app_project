import 'package:equatable/equatable.dart';

class WalletTransactionEntity extends Equatable {
  final dynamic id;
  final String source;
  final double amount;
  final String? orderId;
  final String? title;
  final String? description;
  final String? createdAt;
  final String? status;
  final bool isPending;

  const WalletTransactionEntity({
    required this.id,
    required this.source,
    required this.amount,
    this.orderId,
    this.title,
    this.description,
    this.createdAt,
    this.status,
    this.isPending = false,
  });

  @override
  List<Object?> get props => [
    id,
    source,
    amount,
    orderId,
    title,
    description,
    createdAt,
    status,
    isPending,
  ];
}
