import '../../domain/entities/wallet_pending_withdrawal_entity.dart';

class WalletPendingWithdrawalModel extends WalletPendingWithdrawalEntity {
  const WalletPendingWithdrawalModel({
    required super.id,
    required super.amount,
    required super.status,
    super.createdAt,
  });

  factory WalletPendingWithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WalletPendingWithdrawalModel(
      id: json['id'],
      amount: _toDouble(json['amount']),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? json['date']?.toString(),
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
      'amount': amount,
      'status': status,
      'created_at': createdAt,
    };
  }
}
