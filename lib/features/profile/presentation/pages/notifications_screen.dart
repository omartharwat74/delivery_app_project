import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app_project/core/constants/app_assets.dart';
import 'package:delivery_app_project/core/theme/app_colors.dart';
import 'package:delivery_app_project/core/theme/text_styles.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bg = AppColors.scaffoldBackground(context);
    final fg = AppColors.onSurface(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        leading: BackButton(color: fg, onPressed: () => context.pop()),
        title: Text(
          l10n.drawerNotifications,
          style: AppTextStyles.appBarTitle(context),
        ),
        centerTitle: false,
        titleSpacing: 4.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.emptyNotifications,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noNotificationsYet,
              style: AppTextStyles.body(
                context,
              ).copyWith(color: AppColors.paragraph(context)),
            ),
          ],
        ),
      ),
    );
  }
}
