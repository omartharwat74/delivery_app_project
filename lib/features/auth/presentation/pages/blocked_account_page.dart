import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/auth_primary_button.dart';

class BlockedAccountPage extends StatelessWidget {
  final String? message;

  const BlockedAccountPage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayMessage = message?.isNotEmpty == true
        ? message!
        : (l10n.localeName == 'ar'
            ? 'تم حظر حسابك. يرجى التواصل مع الإدارة.'
            : 'Your account has been blocked. Please contact support.');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.block_rounded,
                            size: 54,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.localeName == 'ar' ? 'الحساب محظور' : 'Account Blocked',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading1(context).copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(context).copyWith(
                          color: AppColors.paragraph(context),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AuthPrimaryButton(
                        label: l10n.registerSignIn,
                        onPressed: () => context.go(RouteNames.login),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
