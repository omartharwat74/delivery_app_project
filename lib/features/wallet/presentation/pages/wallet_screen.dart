import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_transaction_item.dart';
import '../widgets/wallet_warning_banner.dart';
import '../widgets/withdrawal_bottom_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalletCubit>(
      create: (context) => di.sl<WalletCubit>()..fetchWallet(),
      child: const _WalletScreenContent(),
    );
  }
}

class _WalletScreenContent extends StatelessWidget {
  const _WalletScreenContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLtr = Directionality.of(context) == TextDirection.ltr;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground(context),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16.0,
        title: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Transform.flip(
                  flipX: isLtr,
                  child: SvgPicture.asset(
                    'assets/icons/wallet/wallet_back.svg',
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      AppColors.onSurface(context),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n?.walletTitle ?? 'المحفظة',
              style: TextStyle(
                fontFamily: 'ExpoArabic',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: AppColors.onSurface(context),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state.hasError && state.wallet == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage ?? 'حدث خطأ في تحميل بيانات المحفظة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'ExpoArabic',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onSurface(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<WalletCubit>().fetchWallet(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontFamily: 'ExpoArabic',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final wallet = state.wallet;
            if (wallet == null) {
              return const SizedBox.shrink();
            }

            final transactions = wallet.transactions;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<WalletCubit>().fetchWallet(silent: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── 1. Warning Banner (visible if maxDebt > 0) ──
                        if (wallet.maxDebt > 0) ...[
                          WalletWarningBanner(
                            maxDebt: wallet.maxDebt,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // ── 2. Main Balance Card ───────────────────────────
                        WalletBalanceCard(
                          wallet: wallet,
                          onWithdrawPressed: () {
                            WithdrawalBottomSheet.show(
                              context,
                              availableBalance: wallet.availableBalance,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // ── 3. Transaction History Header ───────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              l10n?.transactionHistoryTitle ?? 'سجل المعاملات : ',
                              style: TextStyle(
                                fontFamily: 'ExpoArabic',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                color: AppColors.onSurface(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── 4. Transaction List ─────────────────────────────
                        if (transactions.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            alignment: Alignment.center,
                            child: Text(
                              l10n?.noTransactionsYet ?? 'لا توجد معاملات حتى الآن',
                              style: TextStyle(
                                fontFamily: 'ExpoArabic',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.paragraph(context),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transactions.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              return WalletTransactionItem(transaction: tx);
                            },
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
