import '../../domain/entities/wallet_transaction_entity.dart';
import 'wallet_pending_withdrawal_model.dart';

class WalletTransactionModel extends WalletTransactionEntity {
  const WalletTransactionModel({
    required super.id,
    required super.source,
    required super.amount,
    super.orderId,
    super.title,
    super.description,
    super.createdAt,
    super.status,
    super.isPending,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final rawSource = (json['source'] ?? json['type'] ?? json['action'] ?? '').toString();
    final rawAmount = _toDouble(json['amount']);
    final orderId = json['order_id']?.toString() ??
        json['order_number']?.toString() ??
        json['orderId']?.toString();

    // Map title based on source if not explicitly provided
    String? title = json['title']?.toString();
    if (title == null || title.isEmpty) {
      switch (rawSource) {
        case 'pending_withdrawal':
        case 'withdraw_hold':
          title = 'طلب سحب';
          break;
        case 'order_cash_debt':
          title = 'طلب كاش';
          break;
        case 'order_earning':
          title = 'طلب فيزا';
          break;
        case 'cash_received':
          title = 'تسديد مديونية';
          break;
        default:
          title = json['label']?.toString() ?? 'معاملة';
      }
    }

    // Map description based on source if not explicitly provided
    String? description = json['description']?.toString() ?? json['note']?.toString();
    if (description == null || description.isEmpty) {
      if (rawSource == 'order_cash_debt') {
        description = 'عمولة التطبيق';
      } else if (rawSource == 'order_earning') {
        description = 'رسوم التوصيل';
      }
    }

    // Normalize amount sign according to source rules
    double normalizedAmount = rawAmount;
    if (rawSource == 'withdraw_hold' || rawSource == 'order_cash_debt' || rawSource == 'pending_withdrawal') {
      normalizedAmount = -rawAmount.abs();
    } else if (rawSource == 'order_earning' || rawSource == 'cash_received') {
      normalizedAmount = rawAmount.abs();
    }

    return WalletTransactionModel(
      id: json['id'],
      source: rawSource,
      amount: normalizedAmount,
      orderId: orderId,
      title: title,
      description: description,
      createdAt: json['created_at']?.toString() ?? json['date']?.toString(),
      status: json['status']?.toString(),
      isPending: rawSource == 'pending_withdrawal' || json['status'] == 'pending',
    );
  }

  factory WalletTransactionModel.fromPendingWithdrawal(
    WalletPendingWithdrawalModel pending,
  ) {
    return WalletTransactionModel(
      id: pending.id,
      source: 'pending_withdrawal',
      amount: -pending.amount.abs(),
      orderId: null,
      title: 'طلب سحب',
      description: null,
      createdAt: pending.createdAt,
      status: pending.status,
      isPending: true,
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'amount': amount,
      'order_id': orderId,
      'title': title,
      'description': description,
      'created_at': createdAt,
      'status': status,
      'is_pending': isPending,
    };
  }
}
