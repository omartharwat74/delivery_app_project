import 'package:equatable/equatable.dart';

import 'wallet_pending_withdrawal_entity.dart';
import 'wallet_transaction_entity.dart';

class WalletEntity extends Equatable {
  final double balance;
  final double maxDebt;
  final double debtRoom;
  final WalletPendingWithdrawalEntity? pendingWithdrawal;
  final List<WalletTransactionEntity> transactions;

  const WalletEntity({
    required this.balance,
    required this.maxDebt,
    required this.debtRoom,
    this.pendingWithdrawal,
    required this.transactions,
  });

  /// الرصيد المتاح للسحب: إذا كان الرصيد موجباً يعرض قيمته، وإذا كان سالباً يعرض 0
  double get availableBalance => balance > 0 ? balance : 0.0;

  /// المديونية (كاش معاك): تحسب من (maxDebt - debtRoom) إذا كانت متوفرة، أو القيمة المطلقة للرصيد إذا كان سالباً
  double get debt {
    if (debtRoom > 0 && maxDebt >= debtRoom) {
      return maxDebt - debtRoom;
    }
    if (balance < 0) return balance.abs();
    return 0.0;
  }

  /// نسبة المديونية إلى الحد الأقصى (0.0 إلى 1.0)
  double get debtRatio =>
      maxDebt > 0 ? (debt / maxDebt).clamp(0.0, 1.0) : 0.0;

  /// زر سحب الرصيد مفعّل فقط إذا كان الرصيد موجباً ولا يوجد طلب سحب معلق
  bool get canWithdraw => balance > 0 && pendingWithdrawal == null;

  /// يظهر بانر التحذير إذا كان الحد الأقصى للمديونية محدداً
  bool get isDebtNearMax => maxDebt > 0;

  @override
  List<Object?> get props => [
    balance,
    maxDebt,
    debtRoom,
    pendingWithdrawal,
    transactions,
  ];
}
