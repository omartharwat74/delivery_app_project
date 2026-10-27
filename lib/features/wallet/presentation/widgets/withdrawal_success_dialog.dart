import 'package:flutter/material.dart';

import '../../../../core/widgets/app_success_dialog.dart';
import '../../../../l10n/app_localizations.dart';

class WithdrawalSuccessDialog extends StatelessWidget {
  const WithdrawalSuccessDialog({super.key});

  static Future<void> show(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSuccessDialog.show(
      context,
      message: l10n?.withdrawalSuccessDialog ?? 'تم إرسال طلبك الى الادارة بنجاح',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSuccessDialog(
      message: l10n?.withdrawalSuccessDialog ?? 'تم إرسال طلبك الى الادارة بنجاح',
    );
  }
}
