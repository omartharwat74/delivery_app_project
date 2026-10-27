import 'package:delivery_app_project/features/wallet/data/models/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletModel', () {
    test('should parse correctly without pending_withdrawal', () {
      final json = {
        'balance': 1350.0,
        'max_debt': 500.0,
        'debt_room': 380.0,
        'pending_withdrawal': null,
        'items': [
          {
            'id': 1,
            'source': 'order_earning',
            'amount': 70.0,
            'order_id': '15102',
            'title': 'طلب فيزا',
            'description': 'رسوم التوصيل',
            'created_at': '2026-11-02T10:00:00Z',
          },
          {
            'id': 2,
            'source': 'order_cash_debt',
            'amount': 5.0,
            'order_id': '15102',
            'title': 'طلب كاش',
            'description': 'عمولة التطبيق',
            'created_at': '2026-11-02T10:05:00Z',
          },
        ],
      };

      final model = WalletModel.fromJson(json);

      expect(model.balance, 1350.0);
      expect(model.maxDebt, 500.0);
      expect(model.debtRoom, 380.0);
      expect(model.availableBalance, 1350.0);
      expect(model.debt, 120.0);
      expect(model.canWithdraw, isTrue);
      expect(model.isDebtNearMax, isTrue);
      expect(model.pendingWithdrawal, isNull);
      expect(model.transactions.length, 2);
      expect(model.transactions[0].source, 'order_earning');
      expect(model.transactions[0].amount, 70.0);
      expect(model.transactions[1].source, 'order_cash_debt');
      expect(model.transactions[1].amount, -5.0); // Normalized to negative
    });

    test(
        'CRITICAL: should merge pending_withdrawal as the first item (index 0) with status pending and negative amount',
        () {
      final json = {
        'balance': 1350.0,
        'max_debt': 500.0,
        'debt_room': 380.0,
        'pending_withdrawal': {
          'id': 99,
          'amount': 250.0,
          'status': 'pending',
          'created_at': '2026-11-02T12:00:00Z',
        },
        'items': [
          {
            'id': 1,
            'source': 'cash_received',
            'amount': 500.0,
            'created_at': '2026-11-02T09:00:00Z',
          },
          {
            'id': 2,
            'source': 'order_earning',
            'amount': 70.0,
            'order_id': '15102',
            'created_at': '2026-11-02T08:00:00Z',
          },
        ],
      };

      final model = WalletModel.fromJson(json);

      // Verify pending withdrawal exists and canWithdraw is false
      expect(model.pendingWithdrawal, isNotNull);
      expect(model.canWithdraw, isFalse);

      // Transactions list must have 1 + 2 = 3 items
      expect(model.transactions.length, 3);

      // INDEX 0 MUST BE the pending withdrawal!
      final firstItem = model.transactions[0];
      expect(firstItem.id, 99);
      expect(firstItem.source, 'pending_withdrawal');
      expect(firstItem.title, 'طلب سحب');
      expect(firstItem.amount, -250.0); // Negative
      expect(firstItem.isPending, isTrue);
      expect(firstItem.status, 'pending');

      // Subsequent items
      expect(model.transactions[1].source, 'cash_received');
      expect(model.transactions[1].amount, 500.0);
      expect(model.transactions[2].source, 'order_earning');
    });

    test('should calculate debt and isDebtNearMax correctly when balance is negative', () {
      final json = {
        'balance': -400.0,
        'max_debt': 500.0,
        'debt_room': 100.0,
        'items': [],
      };

      final model = WalletModel.fromJson(json);

      expect(model.availableBalance, 0.0);
      expect(model.debt, 400.0);
      expect(model.debtRatio, 400.0 / 500.0);
      expect(model.canWithdraw, isFalse); // balance <= 0
      expect(model.isDebtNearMax, isTrue); // 400/500 = 80% >= 70%
    });
  });
}
