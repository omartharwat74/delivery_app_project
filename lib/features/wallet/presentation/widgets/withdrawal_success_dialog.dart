import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class WithdrawalSuccessDialog extends StatefulWidget {
  const WithdrawalSuccessDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const WithdrawalSuccessDialog(),
    );
  }

  @override
  State<WithdrawalSuccessDialog> createState() => _WithdrawalSuccessDialogState();
}

class _WithdrawalSuccessDialogState extends State<WithdrawalSuccessDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Image (132x132 from Figma)
              Image.asset(
                'assets/icons/wallet/success_tick.png',
                width: 132,
                height: 132,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                l10n?.withdrawalSuccessDialog ?? 'تم إرسال طلبك الى الادارة بنجاح',
                textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
