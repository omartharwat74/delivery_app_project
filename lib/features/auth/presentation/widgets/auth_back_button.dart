import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/localization/context_locale_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_media.dart';

class AuthBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AuthBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SizedBox(
        width: 28,
        height: 28,
        child: InkWell(
          onTap: onPressed ?? () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
          child: Transform.flip(
            flipX: context.isArabic,
            child: AppSvgImage.asset(
              AppAssets.icBack,
              width: 28,
              height: 28,
              color: AppColors.onSurface(context),
            ),
          ),
        ),
      ),
    );
  }
}
