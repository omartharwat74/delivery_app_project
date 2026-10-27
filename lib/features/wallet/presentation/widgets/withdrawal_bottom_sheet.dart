import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import 'withdrawal_success_dialog.dart';

class WithdrawalBottomSheet extends StatefulWidget {
  final double availableBalance;

  const WithdrawalBottomSheet({
    super.key,
    required this.availableBalance,
  });

  static Future<void> show(BuildContext context, {required double availableBalance}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<WalletCubit>(),
        child: WithdrawalBottomSheet(availableBalance: availableBalance),
      ),
    );
  }

  @override
  State<WithdrawalBottomSheet> createState() => _WithdrawalBottomSheetState();
}

class _WithdrawalBottomSheetState extends State<WithdrawalBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final l10n = AppLocalizations.of(context);
    final text = _amountController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorMessage = l10n?.enterAmountPrompt ?? 'يرجى إدخال مبلغ السحب';
      });
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = l10n?.enterValidAmount ?? 'يرجى إدخال مبلغ صالح أكبر من 0';
      });
      return;
    }

    if (amount > widget.availableBalance) {
      final balanceStr = widget.availableBalance % 1 == 0
          ? widget.availableBalance.toInt().toString()
          : widget.availableBalance.toStringAsFixed(1);
      setState(() {
        _errorMessage = l10n?.amountExceedsBalance(balanceStr) ??
            'المبلغ المطلوب يتجاوز الرصيد المتاح ($balanceStr ج.م)';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Call cubit to submit withdrawal
    context.read<WalletCubit>().submitWithdrawal(amount).then((success) {
      if (!mounted) return;
      if (success) {
        // Close BottomSheet
        Navigator.of(context).pop();
        // Show Success Dialog
        WithdrawalSuccessDialog.show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {
        if (state.withdrawalStatus == WithdrawalStatus.error &&
            state.withdrawalError != null) {
          setState(() {
            _errorMessage = state.withdrawalError;
          });
        }
      },
      builder: (context, state) {
        final isLoading = state.isWithdrawing;

        return AnimatedPadding(
          padding: EdgeInsets.only(bottom: bottomInset),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header: Close 'X' Button on Screen Edge & Title Next to it (Gap: 4) ──
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: Icon(
                                Icons.close_rounded,
                                size: 24,
                                color: AppColors.onSurface(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n?.withdrawBalanceModalTitle ?? 'سحب رصيد',
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
                    const SizedBox(height: 20),

                    // ── Body: Input Label & Field ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n?.withdrawalAmountLabel ?? 'مبلغ السحب',
                            style: TextStyle(
                              fontFamily: 'ExpoArabic',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                              color: AppColors.onSurface(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard(context),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _errorMessage != null
                                    ? AppColors.error
                                    : AppColors.border(context),
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                              ],
                              onChanged: (_) {
                                if (_errorMessage != null) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                }
                              },
                              style: TextStyle(
                                fontFamily: 'ExpoArabic',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurface(context),
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: l10n?.enterWithdrawalAmountHint ?? 'ادخل مبلغ السحب',
                                hintStyle: TextStyle(
                                  fontFamily: 'ExpoArabic',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                  color: AppColors.hint(context),
                                ),
                                suffixText: l10n?.currencyEgp ?? 'ج.م',
                                suffixStyle: TextStyle(
                                  fontFamily: 'ExpoArabic',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.paragraph(context),
                                ),
                              ),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontFamily: 'ExpoArabic',
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Bottom Fixed Action Container with Shadow ───────────────
                    Container(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard(context),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0x40000000)
                                : const Color(0x142C2B2B), // rgba(44, 43, 43, 0.08)
                            offset: const Offset(0, 0),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _validateAndSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: const Color(0xFFFFFFFF),
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  l10n?.confirmButton ?? 'تأكيد',
                                  style: const TextStyle(
                                    fontFamily: 'ExpoArabic',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.25,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
