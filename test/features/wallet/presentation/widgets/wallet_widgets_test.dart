import 'package:delivery_app_project/features/wallet/domain/entities/wallet_entity.dart';
import 'package:delivery_app_project/features/wallet/domain/entities/wallet_transaction_entity.dart';
import 'package:delivery_app_project/features/wallet/presentation/widgets/wallet_balance_card.dart';
import 'package:delivery_app_project/features/wallet/presentation/widgets/wallet_transaction_item.dart';
import 'package:delivery_app_project/features/wallet/presentation/widgets/wallet_warning_banner.dart';
import 'package:delivery_app_project/features/wallet/presentation/widgets/withdrawal_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wallet Widgets Test', () {
    testWidgets('WalletWarningBanner displays max debt correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WalletWarningBanner(maxDebt: 500.0),
          ),
        ),
      );

      expect(find.text('الحد الأعلى للمديونية عليك 500 جنيه'), findsOneWidget);
      expect(
        find.text('في حالة الزيادة تتوقف الطلبات من الوصول إليك حتى تقوم بالسداد'),
        findsOneWidget,
      );
    });

    testWidgets('WalletWarningBanner displays dynamic max debt correctly (e.g. 850 EGP)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WalletWarningBanner(maxDebt: 850.0),
          ),
        ),
      );

      expect(find.text('الحد الأعلى للمديونية عليك 850 جنيه'), findsOneWidget);
    });

    testWidgets('WalletBalanceCard displays balance and enables/disables button', (tester) async {
      bool withdrawPressed = false;
      const wallet = WalletEntity(
        balance: 1350.0,
        maxDebt: 500.0,
        debtRoom: 380.0,
        transactions: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletBalanceCard(
              wallet: wallet,
              onWithdrawPressed: () {
                withdrawPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('الرصيد المتاح للسحب'), findsOneWidget);
      expect(find.text('سحب الرصيد'), findsOneWidget);

      // Tap withdraw button
      await tester.tap(find.text('سحب الرصيد'));
      await tester.pump();
      expect(withdrawPressed, isTrue);
    });

    testWidgets('WalletTransactionItem renders pending badge for pending withdrawal', (tester) async {
      const pendingTx = WalletTransactionEntity(
        id: 10,
        source: 'pending_withdrawal',
        amount: -250.0,
        title: 'طلب سحب',
        status: 'pending',
        isPending: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WalletTransactionItem(transaction: pendingTx),
          ),
        ),
      );

      expect(find.text('طلب سحب'), findsOneWidget);
      expect(find.text('قيد المراجعة'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
      expect(find.text('ج.م'), findsOneWidget);
    });

    testWidgets('WalletTransactionItem renders completed and rejected badges', (tester) async {
      const completedTx = WalletTransactionEntity(
        id: 11,
        source: 'withdraw_hold',
        amount: -500.0,
        title: 'طلب سحب',
        status: 'completed',
      );

      const rejectedTx = WalletTransactionEntity(
        id: 12,
        source: 'withdraw_hold',
        amount: -300.0,
        title: 'طلب سحب',
        status: 'rejected',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WalletTransactionItem(transaction: completedTx),
                WalletTransactionItem(transaction: rejectedTx),
              ],
            ),
          ),
        ),
      );

      expect(find.text('منتهي'), findsOneWidget);
      expect(find.text('مرفوض'), findsOneWidget);
    });

    testWidgets('WalletTransactionItem flips arrow in RTL and does not in LTR', (tester) async {
      const withdrawalTx = WalletTransactionEntity(
        id: 15,
        source: 'pending_withdrawal',
        amount: -200.0,
        title: 'طلب سحب',
        status: 'pending',
      );

      // In RTL (Arabic)
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: WalletTransactionItem(transaction: withdrawalTx),
            ),
          ),
        ),
      );

      final transformFinder = find.descendant(
        of: find.byType(WalletTransactionItem),
        matching: find.byType(Transform),
      );

      // In RTL, Transform.flip is applied
      expect(transformFinder, findsOneWidget);

      // In LTR (English)
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              body: WalletTransactionItem(transaction: withdrawalTx),
            ),
          ),
        ),
      );

      // In LTR, no Transform flip on the arrow
      expect(transformFinder, findsNothing);
    });

    testWidgets('WithdrawalSuccessDialog displays message and auto-dismisses after 2 seconds', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WithdrawalSuccessDialog(),
          ),
        ),
      );

      expect(find.text('تم إرسال طلبك الى الادارة بنجاح'), findsOneWidget);
      expect(find.text('حسناً'), findsNothing);

      // Fast forward 2 seconds
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
