import '../../domain/entities/wallet_entity.dart';
import 'wallet_pending_withdrawal_model.dart';
import 'wallet_transaction_model.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.balance,
    required super.maxDebt,
    required super.debtRoom,
    super.pendingWithdrawal,
    required super.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final map = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final balance = _toDouble(map['balance']);
    final maxDebt = _toDouble(map['max_debt'] ?? map['maxDebt']);
    final debtRoom = _toDouble(map['debt_room'] ?? map['debtRoom']);

    WalletPendingWithdrawalModel? pendingWithdrawal;
    if (map['pending_withdrawal'] != null &&
        map['pending_withdrawal'] is Map<String, dynamic>) {
      pendingWithdrawal = WalletPendingWithdrawalModel.fromJson(
        map['pending_withdrawal'] as Map<String, dynamic>,
      );
    }

    final List<WalletTransactionModel> items = [];
    if (map['items'] != null && map['items'] is List) {
      for (final item in (map['items'] as List)) {
        if (item is Map<String, dynamic>) {
          items.add(WalletTransactionModel.fromJson(item));
        }
      }
    }

    // Transaction merging logic:
    // If pending_withdrawal is not null, convert it to a transaction item
    // and make it the FIRST item (index 0) in the list.
    final List<WalletTransactionModel> mergedTransactions = [];
    if (pendingWithdrawal != null) {
      mergedTransactions.add(
        WalletTransactionModel.fromPendingWithdrawal(pendingWithdrawal),
      );
    }
    mergedTransactions.addAll(items);

    return WalletModel(
      balance: balance,
      maxDebt: maxDebt,
      debtRoom: debtRoom,
      pendingWithdrawal: pendingWithdrawal,
      transactions: mergedTransactions,
    );
  }

  /// Mock data matching Figma design (balance: 1350, maxDebt: 500, debt: 380, mock transactions)
  factory WalletModel.mock() {
    return const WalletModel(
      balance: 1350.0,
      maxDebt: 500.0,
      debtRoom: 120.0, // 500 - 120 = 380.0 EGP debt (fills ~76% of progress bar)
      pendingWithdrawal: null,
      transactions: [
        WalletTransactionModel(
          id: 101,
          source: 'pending_withdrawal',
          amount: -250.0,
          title: 'طلب سحب',
          status: 'pending',
          isPending: true,
          createdAt: '2026-11-02T13:00:00Z',
        ),
        WalletTransactionModel(
          id: 102,
          source: 'withdraw_hold',
          amount: -500.0,
          title: 'طلب سحب',
          status: 'completed',
          isPending: false,
          createdAt: '2026-11-01T15:30:00Z',
        ),
        WalletTransactionModel(
          id: 103,
          source: 'withdraw_hold',
          amount: -300.0,
          title: 'طلب سحب',
          status: 'rejected',
          isPending: false,
          createdAt: '2026-10-31T11:00:00Z',
        ),
        WalletTransactionModel(
          id: 1,
          source: 'cash_received',
          amount: 500.0,
          title: 'تسديد مديونية',
          createdAt: '2026-10-30T11:00:00Z',
        ),
        WalletTransactionModel(
          id: 2,
          source: 'order_earning',
          amount: 70.0,
          title: 'طلب فيزا',
          description: 'رسوم التوصيل',
          orderId: '15102',
          createdAt: '2026-10-29T10:30:00Z',
        ),
        WalletTransactionModel(
          id: 3,
          source: 'order_cash_debt',
          amount: -5.0,
          title: 'طلب كاش',
          description: 'عمولة التطبيق',
          orderId: '15102',
          createdAt: '2026-10-29T09:15:00Z',
        ),
        WalletTransactionModel(
          id: 4,
          source: 'order_earning',
          amount: 65.0,
          title: 'طلب فيزا',
          description: 'رسوم التوصيل',
          orderId: '15099',
          createdAt: '2026-10-28T18:40:00Z',
        ),
        WalletTransactionModel(
          id: 5,
          source: 'order_cash_debt',
          amount: -10.0,
          title: 'طلب كاش',
          description: 'عمولة التطبيق',
          orderId: '15098',
          createdAt: '2026-10-28T17:20:00Z',
        ),
      ],
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
}
